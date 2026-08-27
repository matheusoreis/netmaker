extends Node2D
class_name Main


var _action_handler: ActionHandler
var _auth_handler: AuthHandler
var _character_handler: CharacterHandler
var _map_handler: MapHandler

var current_scene: Scene


func _init() -> void:
	if not _setup_network():
		return

	Network.connected.connect(_on_connected)
	Network.disconnected.connect(_on_disconnected)


func _setup_network() -> bool:
	print("Iniciando cliente em %s:%d" % [
		Constants.HOST,
		Constants.PORT,
	])

	var err: Error = Network.start(Constants.HOST, Constants.PORT)
	if err != OK:
		push_error("Erro ao iniciar o cliente (%s)." % error_string(err))
		return false

	print("Cliente iniciado com sucesso!")
	return true


func _setup_handlers() -> bool:
	_action_handler = ActionHandler.new()
	var action: Error = _auth_handler.register()
	if action != OK:
		return false

	_auth_handler = AuthHandler.new()
	var auth_err: Error = _auth_handler.register()
	if auth_err != OK:
		return false

	_character_handler = CharacterHandler.new()
	var character_err: Error = _character_handler.register()
	if character_err != OK:
		return false

	_map_handler = MapHandler.new()
	var map_err: Error = _map_handler.register()
	if map_err != OK:
		return false

	return true


func _on_connected() -> void:
	go_to_menu()


func _on_disconnected() -> void:
	go_to_menu()


func go_to_menu() -> void:
	_change_scene("res://source/scenes/menu.tscn")


func go_to_game() -> void:
	_change_scene("res://source/scenes/game.tscn")


func _change_scene(scene_path: String) -> void:
	var packed: PackedScene = load(scene_path)
	var scene: Node = packed.instantiate()

	current_scene = scene
	add_child(scene)
