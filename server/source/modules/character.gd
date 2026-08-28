extends RefCounted
class_name CharacterModule


## Personagens conectados indexados pelo identificador do peer.
var _characters: Dictionary[int, Character] = {}


## Adiciona um personagem associado a um peer.
func add(peer_id: int, character: Character) -> void:
	if has(peer_id):
		return
	_characters[peer_id] = character


## Remove o personagem associado a um peer.
func remove(peer_id: int) -> void:
	if not has(peer_id):
		return
	_characters.erase(peer_id)


## Retorna o personagem associado a um peer.
func character(peer_id: int) -> Character:
	return _characters.get(peer_id)


## Indica se existe um personagem associado ao peer.
func has(peer_id: int) -> bool:
	return _characters.has(peer_id)


## Retorna a quantidade de personagens conectados.
func count() -> int:
	return _characters.size()


## Retorna todos os personagens conectados.
func all() -> Array[Character]:
	return _characters.values()


## Retorna o peer associado ao identificador do personagem.
func get_peer_by_character_id(character_id: int) -> int:
	for peer_id: int in _characters:
		if _characters[peer_id].id == character_id:
			return peer_id
	return -1


## Retorna os peers que estão no mapa informado.
func get_peers_in_map(map_id: int) -> Array[int]:
	var result: Array[int] = []
	for peer_id: int in _characters:
		if _characters[peer_id].map == map_id:
			result.append(peer_id)
	return result


## Retorna todos os identificadores de peers registrados.
func get_all_peers() -> Array[int]:
	return _characters.keys()


## Remove todos os personagens conectados.
func clear() -> void:
	_characters.clear()
