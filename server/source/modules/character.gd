extends RefCounted
class_name CharacterModule


var _characters: Dictionary[int, Character] = {}


func add(peer_id: int, character: Character) -> void:
	if has(peer_id):
		return
	_characters[peer_id] = character


func remove(peer_id: int) -> void:
	if not has(peer_id):
		return
	_characters.erase(peer_id)


func character(peer_id: int) -> Character:
	return _characters.get(peer_id)


func has(peer_id: int) -> bool:
	return _characters.has(peer_id)


func count() -> int:
	return _characters.size()


func all() -> Array[Character]:
	return _characters.values()


func get_peer_by_character_id(character_id: int) -> int:
	for peer_id: int in _characters:
		if _characters[peer_id].id == character_id:
			return peer_id
	return -1


func get_peers_in_map(map_id: int) -> Array[int]:
	var result: Array[int] = []
	for peer_id: int in _characters:
		if _characters[peer_id].map == map_id:
			result.append(peer_id)
	return result


func get_all_peers() -> Array[int]:
	return _characters.keys()


func clear() -> void:
	_characters.clear()
