extends Node


const SCENES_PATH: String = "res://source/scene/"


var _current_scene: Scene = null
var _current_scene_name: String = ""
var _scene_stack: Array[String] = []


func load_scene(scene_name: String) -> void:
	var scene: Scene = _instantiate_scene(scene_name)
	if not scene:
		return

	if _current_scene:
		_current_scene.queue_free()

	add_child(scene)
	_current_scene = scene
	_current_scene_name = scene_name


func push_scene(scene_name: String) -> void:
	var scene: Scene = _instantiate_scene(scene_name)
	if not scene:
		return

	if _current_scene:
		_scene_stack.push_back(_current_scene_name)
		_current_scene.queue_free()

	add_child(scene)
	_current_scene = scene
	_current_scene_name = scene_name


func pop_scene() -> void:
	if _scene_stack.is_empty():
		push_warning("GameScenes: Nenhuma cena na pilha para voltar")
		return

	if _current_scene:
		_current_scene.queue_free()
		_current_scene = null

	var previous_scene_name: String = _scene_stack.pop_back()
	load_scene(previous_scene_name)


func read_current_scene() -> Scene:
	return _current_scene


func unload_scene() -> void:
	if _current_scene:
		_current_scene.queue_free()
		_current_scene = null

	_current_scene_name = ""


func clear_all() -> void:
	_scene_stack.clear()

	if _current_scene:
		_current_scene.queue_free()
		_current_scene = null

	_current_scene_name = ""


func has_scene_loaded() -> bool:
	return _current_scene != null


func read_scene_stack_size() -> int:
	return _scene_stack.size()


func _instantiate_scene(scene_name: String) -> Scene:
	var path: String = "%s%s/%s.tscn" % [SCENES_PATH, scene_name, scene_name]

	if not ResourceLoader.exists(path):
		push_error("Cena não encontrada: ", path)
		return null

	var scene_scene: PackedScene = load(path)
	return scene_scene.instantiate()
