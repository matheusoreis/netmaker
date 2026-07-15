extends Node


const SCENES_PATH: String = "res://source/scene/"


var _current_scene: Scene = null
var _scene_stack: Array[String] = []


func load_scene(scene_name: String) -> void:
	var path: String = "%s%s/%s.tscn" % [SCENES_PATH, scene_name, scene_name]

	if not ResourceLoader.exists(path):
		push_error("Cena não encontrada: ", path)
		return

	var scene_scene: PackedScene = load(path)
	var scene: Scene = scene_scene.instantiate()

	if _current_scene:
		_current_scene.queue_free()

	add_child(scene)
	_current_scene = scene


func push_scene(scene_name: String) -> void:
	var path: String = "%s%s/%s.tscn" % [SCENES_PATH, scene_name, scene_name]

	if not ResourceLoader.exists(path):
		push_error("Cena não encontrada: ", path)
		return

	# Guarda o nome da cena atual na pilha
	if _current_scene:
		var current_name: String = _current_scene.name
		_scene_stack.push_back(current_name)
		_current_scene.queue_free()

	var scene_scene: PackedScene = load(path)
	var scene: Scene = scene_scene.instantiate()

	add_child(scene)
	_current_scene = scene


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


func clear_all() -> void:
	_scene_stack.clear()

	if _current_scene:
		_current_scene.queue_free()
		_current_scene = null


func has_scene_loaded() -> bool:
	return _current_scene != null


func read_scene_stack_size() -> int:
	return _scene_stack.size()
