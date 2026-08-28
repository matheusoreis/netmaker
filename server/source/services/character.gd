extends RefCounted
class_name CharacterService


## Repositório responsável pelos dados dos personagens.
var _character_repository: CharacterRepository
## Módulo que mantém os personagens conectados.
var _character_module: CharacterModule


## Cria um serviço de personagens.
func _init(character_repository: CharacterRepository, character_module: CharacterModule) -> void:
	_character_repository = character_repository
	_character_module = character_module


## Retorna os dados dos personagens de uma conta.
func list_characters(account_id: int) -> Array:
	var characters: Array[Models.CharacterModel] = await _character_repository.get_characters_by_account(account_id)

	var characters_data: Array = []
	for character in characters:
		characters_data.append(character.to_array())

	return characters_data


## Indica se um personagem está conectado.
func is_character_online(character_id: int) -> bool:
	return _character_module.get_peer_by_character_id(character_id) != -1


## Cria um personagem para uma conta.
func create_character(account_id: int, identifier: String, spritesheet: String) -> Array:
	return await _character_repository.create_character(account_id, identifier, spritesheet)


## Seleciona um personagem e associa-o ao peer.
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


## Exclui um personagem e remove sua associação com o peer.
func delete_character(peer_id: int, character_id: int, account_id: int) -> Array:
	var result: Array = await _character_repository.delete_character(character_id, account_id)
	if result[0] != OK:
		return result

	if _character_module.has(peer_id) and _character_module.character(peer_id).id == character_id:
		_character_module.remove(peer_id)

	return [OK, null]


## Retorna o personagem associado a um peer.
func get_character(peer_id: int) -> Character:
	return _character_module.character(peer_id)


## Indica se um peer possui um personagem selecionado.
func has_character(peer_id: int) -> bool:
	return _character_module.has(peer_id)


## Retorna os peers presentes no mapa informado.
func get_peers_in_map(map_id: int) -> Array[int]:
	return _character_module.get_peers_in_map(map_id)


## Retorna todos os peers com personagens selecionados.
func get_all_peers() -> Array[int]:
	return _character_module.get_all_peers()


## Move um personagem se o caminho estiver livre.
func move_character(peer_id: int, direction: Vector2i, map: Map) -> bool:
	var character: Character = _character_module.character(peer_id)
	if character == null:
		return false

	if not map.can_pass(character.cell, direction):
		return false

	character.move(direction)
	return true


## Transfere um personagem para outro mapa e atualiza sua posição.
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


## Salva a posição e a direção atuais de um personagem.
func save_character_position(peer_id: int) -> void:
	var character: Character = _character_module.character(peer_id)
	if character == null:
		return

	await _character_repository.update_character_position(
		character.id,
		character.cell,
		character.facing
	)


## Salva os dados do personagem e remove-o dos personagens conectados.
func unload_character(peer_id: int) -> void:
	if not _character_module.has(peer_id):
		return

	var character: Character = _character_module.character(peer_id)
	await _character_repository.update_character_position(character.id, character.cell, character.facing)
	await _character_repository.update_access(character.id)

	_character_module.remove(peer_id)


## Retorna um personagem conectado pelo seu identificador.
func get_character_by_id(character_id: int) -> Character:
	var peer_id: int = _character_module.get_peer_by_character_id(character_id)
	if peer_id == -1:
		return null
	return _character_module.character(peer_id)
