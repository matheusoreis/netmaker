extends RefCounted
class_name CharacterService


var _character_repository: CharacterRepository
var _character_module: CharacterModule


func _init(character_repository: CharacterRepository, character_module: CharacterModule) -> void:
	_character_repository = character_repository
	_character_module = character_module


func list_characters(account_id: int) -> Array:
	var characters: Array[Models.CharacterModel] = await _character_repository.get_characters_by_account(account_id)

	var characters_data: Array = []
	for character in characters:
		characters_data.append(character.to_array())

	return characters_data


func is_character_online(character_id: int) -> bool:
	return _character_module.get_peer_by_character_id(character_id) != -1


func create_character(account_id: int, identifier: String, spritesheet: String) -> Array:
	return await _character_repository.create_character(account_id, identifier, spritesheet)


func select_character(peer_id: int, character_id: int, account_id: int) -> Array:
	var result: Array = await _character_repository.select_character(character_id, account_id)
	if result[0] != OK:
		return result

	var model: Models.CharacterModel = result[1] as Models.CharacterModel

	var character: Character = Character.new(
		model.id,
		model.identifier,
		model.spritesheet,
		model.map,
		Vector2i(model.cell_x, model.cell_y),
		Vector2i(model.facing_x, model.facing_y),
		model.account
	)

	_character_module.add(peer_id, character)

	return [OK, character]


func delete_character(peer_id: int, character_id: int, account_id: int) -> Array:
	var result: Array = await _character_repository.delete_character(character_id, account_id)
	if result[0] != OK:
		return result

	if _character_module.has(peer_id) and _character_module.character(peer_id).id == character_id:
		_character_module.remove(peer_id)

	return [OK, null]


func get_character(peer_id: int) -> Character:
	return _character_module.character(peer_id)


func has_character(peer_id: int) -> bool:
	return _character_module.has(peer_id)


func get_peers_in_map(map_id: int) -> Array[int]:
	return _character_module.get_peers_in_map(map_id)


func move_character(peer_id: int, direction: Vector2i, map: Map) -> bool:
	var character: Character = _character_module.character(peer_id)
	if character == null:
		return false

	if not map.can_pass(character.cell, direction):
		return false

	character.move(direction)
	return true


func warp_character(peer_id: int, to_map_id: int, to_cell: Vector2i, to_facing: Vector2i) -> bool:
	var character: Character = _character_module.character(peer_id)
	if character == null:
		return false

	character.map = to_map_id
	character.cell = to_cell
	character.facing = to_facing

	var result: Array = await _character_repository.update_character_map(
		character.id,
		to_map_id,
		to_cell,
		to_facing
	)

	return result[0] == OK


func save_character_position(peer_id: int) -> void:
	var character: Character = _character_module.character(peer_id)
	if character == null:
		return

	await _character_repository.update_character_position(
		character.id,
		character.cell,
		character.facing
	)


func unload_character(peer_id: int) -> void:
	if not _character_module.has(peer_id):
		return

	var character: Character = _character_module.character(peer_id)
	await _character_repository.update_character_position(character.id, character.cell, character.facing)
	await _character_repository.update_access(character.id)

	_character_module.remove(peer_id)


func get_character_by_id(character_id: int) -> Character:
	var peer_id: int = _character_module.get_peer_by_character_id(character_id)
	if peer_id == -1:
		return null
	return _character_module.character(peer_id)
