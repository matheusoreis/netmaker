extends RefCounted
class_name MapService


var _map_repository: MapRepository
var _map_module: MapModule


func _init(map_repository: MapRepository, map_module: MapModule) -> void:
	_map_repository = map_repository
	_map_module = map_module


func load_all_maps() -> void:
	var map_models: Array[Models.MapModel] = await _map_repository.get_all_maps()

	for map_model in map_models:
		await _load_map_from_model(map_model)


func load_map(map_id: int) -> bool:
	if _map_module.has(map_id):
		return true

	var map_model: Models.MapModel = await _map_repository.get_map(map_id)
	if map_model == null:
		push_error("Mapa %d não encontrado no banco" % map_id)
		return false

	await _load_map_from_model(map_model)
	return true


func get_map(map_id: int) -> Map:
	return _map_module.map(map_id)


func has_map(map_id: int) -> bool:
	return _map_module.has(map_id)


func reload_map(map_id: int) -> bool:
	if _map_module.has(map_id):
		_map_module.remove(map_id)
	return await load_map(map_id)


func create_map(id: int, identifier: String, bgm: String, bgs: String, size: Vector2i) -> bool:
	if _map_module.has(id):
		push_error("Mapa %d já está carregado" % id)
		return false

	var success: bool = await _map_repository.create_map(id, identifier, bgm, bgs, size)
	if not success:
		push_error("Falha ao criar mapa %d" % id)
		return false

	return await load_map(id)


func update_map(
	map_id: int,
	identifier: String,
	bgm: String,
	bgs: String,
	size: Vector2i,
	new_collisions: Array,
	new_warps: Array
) -> bool:
	var map: Map = _map_module.map(map_id)
	if not map:
		push_error("Mapa %d não encontrado" % map_id)
		return false

	if not await _map_repository.update_map(map_id, identifier, bgm, bgs, size):
		push_error("Falha ao salvar dados do mapa %d" % map_id)
		return false

	if not await _map_repository.delete_collisions_by_map(map_id):
		push_error("Falha ao salvar dados do mapa %d" % map_id)
		return false

	for entry in new_collisions:
		var cell: Vector2i = entry[0]
		var flag: int = entry[1]

		if not await _map_repository.insert_collision(map_id, cell, flag):
			push_error("Falha ao salvar dados do mapa %d" % map_id)
			return false

	if not await _map_repository.delete_warps_by_map(map_id):
		push_error("Falha ao salvar dados do mapa %d" % map_id)
		return false

	for entry in new_warps:
		var from_cell: Vector2i = entry[0]
		var to_map_id: int = entry[1]
		var to_cell: Vector2i = entry[2]
		var to_facing: Vector2i = entry[3]

		if not await _map_repository.insert_warp(map_id, from_cell, to_map_id, to_cell, to_facing):
			push_error("Falha ao salvar dados do mapa %d" % map_id)
			return false

	var collisions_dict: Dictionary[Vector2i, int] = {}
	for entry in new_collisions:
		collisions_dict[entry[0]] = entry[1]

	var warps_dict: Dictionary[Vector2i, Dictionary] = {}
	for entry in new_warps:
		warps_dict[entry[0]] = {
			"to_map_id": entry[1],
			"to_cell": entry[2],
			"to_facing": entry[3]
		}

	map.identifier = identifier
	map.bgm = bgm
	map.bgs = bgs
	map.size = size
	map.import_collisions(collisions_dict)
	map.import_warps(warps_dict)

	return true


func validate_warp(map_id: int, cell: Vector2i) -> Dictionary:
	var map: Map = _map_module.map(map_id)
	if not map:
		return {}

	if not map.has_warp(cell):
		return {}

	var warp: Dictionary = map.get_warp(cell)

	if not _map_module.has(warp["to_map_id"]):
		return {}

	return warp


func _load_map_from_model(map_model: Models.MapModel) -> void:
	var map: Map = Map.new(
		map_model.id,
		map_model.identifier,
		map_model.bgm,
		map_model.bgs,
		Vector2i(map_model.size_x, map_model.size_y)
	)

	var collisions: Dictionary[Vector2i, int] = await _map_repository.get_collisions(map_model.id)
	if not collisions.is_empty():
		map.import_collisions(collisions)

	var warps: Dictionary[Vector2i, Dictionary] = await _map_repository.get_warps(map_model.id)
	if not warps.is_empty():
		map.import_warps(warps)

	_map_module.add(map)

	print("Mapa %d carregado: %s (%dx%d) com %d colisões e %d warps" % [
		map.id,
		map.identifier,
		map.size.x,
		map.size.y,
		map.collisions.size(),
		map.warps.size()
	])
