extends RefCounted
class_name CharacterModule


## Personagens carregados na memória.
var _characters: Dictionary[int, Character] = {}


## Adiciona um personagem ao peer.
func add(peer_id: int, character: Character) -> void:
	if has(peer_id):
		return

	_characters[peer_id] = character


## Remove o personagem de um peer.
func remove(peer_id: int) -> void:
	if not has(peer_id):
		return

	_characters.erase(peer_id)


## Retorna o personagem de um peer.
func character(peer_id: int) -> Character:
	return _characters.get(peer_id)


## Verifica se um peer possui um personagem.
func has(peer_id: int) -> bool:
	return _characters.has(peer_id)


## Retorna a quantidade de personagens.
func count() -> int:
	return _characters.size()


## Retorna todos os personagens.
func all() -> Array[Character]:
	return _characters.values()


## Retorna os peers que estão em um mapa.
func in_map(map: int) -> Array:
	var result: Array = []

	for peer_id: int in _characters:
		if _characters[peer_id].map == map:
			result.append(peer_id)

	return result


## Verifica se um personagem possui o ID informado.
func has_character_id(character_id: int) -> bool:
	for character in all():
		if character.id == character_id:
			return true
	return false


## Move um personagem na direção informada.
func move(peer_id: int, direction: Vector2i, map: Map) -> bool:
	var character: Character = character(peer_id)
	if character == null:
		return false

	if not map.can_pass(character.cell, direction):
		return false

	character.move(direction)

	return true
