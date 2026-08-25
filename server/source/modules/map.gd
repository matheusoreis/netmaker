extends RefCounted
class_name MapModule


var _maps: Dictionary[int, Map] = {}


func add(map: Map) -> void:
	if has(map.id):
		return
	_maps[map.id] = map


func remove(map_id: int) -> void:
	if not has(map_id):
		return
	_maps.erase(map_id)


func map(map_id: int) -> Map:
	return _maps.get(map_id)


func has(map_id: int) -> bool:
	return _maps.has(map_id)


func count() -> int:
	return _maps.size()


func all() -> Array[Map]:
	return _maps.values()


func clear() -> void:
	_maps.clear()
