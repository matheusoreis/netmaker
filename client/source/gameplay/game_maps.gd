extends Node


const MAPS_PATH: String = "res://data/maps/"


var _current_map: Map = null


func load_map(map_name: String) -> Map:
	var path: String = MAPS_PATH + map_name + ".tscn"

	if not ResourceLoader.exists(path):
		push_error("Mapa não encontrado: ", path)
		return null

	var map_scene: PackedScene = load(path)
	var map: Map = map_scene.instantiate()

	var old_map: Map = _current_map
	_current_map = map

	if old_map:
		old_map.queue_free()

	return map


func read_map() -> Map:
	return _current_map


func unload_map() -> void:
	if _current_map:
		_current_map.queue_free()
		_current_map = null


func has_map_loaded() -> bool:
	return _current_map != null
