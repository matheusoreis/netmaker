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
			map_model.id,
			map.identifier,
			map.size.x,
			map.size.y,
			map.collisions.size(),
			map.warps.size()
		])


func load_map(map_id: int) -> bool:
	if _map_module.has(map_id):
		return true

	var map_model: Models.MapModel = await _map_repository.get_map(map_id)
	if map_model == null:
		push_error("Mapa %d não encontrado no banco" % map_id)
		return false

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
	return true


func get_map(map_id: int) -> Map:
	return _map_module.map(map_id)


func has_map(map_id: int) -> bool:
	return _map_module.has(map_id)


func reload_map(map_id: int) -> bool:
	if _map_module.has(map_id):
		_map_module.remove(map_id)
	return await load_map(map_id)


func update_collisions(map_id: int, new_collisions: Dictionary[Vector2i, int]) -> bool:
	var map: Map = _map_module.map(map_id)
	if not map:
		push_error("Mapa %d não encontrado" % map_id)
		return false

	map.import_collisions(new_collisions)

	var success: bool = await _map_repository.update_collisions(map_id, new_collisions)
	if not success:
		push_error("Falha ao salvar colisões do mapa %d" % map_id)
		return false

	return true


func create_map(id: int, identifier: String, bgm: String, bgs: String, size: Vector2i) -> bool:
	if _map_module.has(id):
		push_error("Mapa %d já está carregado" % id)
		return false

	var success: bool = await _map_repository.create_map(id, identifier, bgm, bgs, size)
	if not success:
		push_error("Falha ao criar mapa %d" % id)
		return false

	return await load_map(id)


func delete_map(map_id: int) -> bool:
	await _map_repository.delete_warps_by_map(map_id)
	_map_module.remove(map_id)
	return await _map_repository.delete_map(map_id)


func validate_warp(map_id: int, cell: Vector2i) -> Dictionary:
	var warp: Dictionary = await _map_repository.get_warp_by_cell(map_id, cell.x, cell.y)
	if warp.is_empty():
		return {}

	var target_map_exists: bool = await _map_repository.map_exists(warp["to_map_id"])
	if not target_map_exists:
		return {}

	return warp


func get_warps(map_id: int) -> Dictionary[Vector2i, Dictionary]:
	return await _map_repository.get_warps(map_id)


func create_warp(map_id: int, from_cell: Vector2i, to_map_id: int, to_cell: Vector2i, to_facing: Vector2i) -> bool:
	if await _map_repository.warp_exists(map_id, from_cell.x, from_cell.y):
		push_error("Warp já existe na célula %s do mapa %d" % [from_cell, map_id])
		return false

	if not await _map_repository.map_exists(to_map_id):
		push_error("Mapa destino %d não existe" % to_map_id)
		return false

	var success: bool = await _map_repository.create_warp(map_id, from_cell, to_map_id, to_cell, to_facing)
	if not success:
		push_error("Falha ao criar warp no mapa %d" % map_id)
		return false

	await reload_map(map_id)
	return true


func delete_warp(map_id: int, cell: Vector2i) -> bool:
	var success: bool = await _map_repository.delete_warp(map_id, cell.x, cell.y)
	if not success:
		push_error("Falha ao deletar warp da célula %s do mapa %d" % [cell, map_id])
		return false

	await reload_map(map_id)
	return true


func delete_warps_by_map(map_id: int) -> bool:
	var success: bool = await _map_repository.delete_warps_by_map(map_id)
	if not success:
		push_error("Falha ao deletar warps do mapa %d" % map_id)
		return false

	await reload_map(map_id)
	return true
