extends Node


var _current_map: Map = null


func load_map(id: int, identifier: String, bgm: String, bgs: String, width: int, height: int) -> void:
	var path: String = Constants.MAPS_PATH + "map_%d.tscn" % id

	if not ResourceLoader.exists(path):
		push_error("Mapa não encontrado: ", path)
		return

	var map_scene: PackedScene = load(path)
	var map: Map = map_scene.instantiate()

	map.setup(id, identifier, bgm, bgs, width, height)
	_set_current_map(map)


func _set_current_map(map: Map) -> void:
	if _current_map:
		_current_map.queue_free()

	_current_map = map


func current_map() -> Map:
	return _current_map


func unload_map() -> void:
	if _current_map:
		_current_map.queue_free()
		_current_map = null


func has_map_loaded() -> bool:
	return _current_map != null
