extends Node2D
class_name Main


## Handlers responsáveis pelas operações do cliente.
var _action_handler: ActionHandler
var _auth_handler: AuthHandler
var _character_handler: CharacterHandler
var _map_handler: MapHandler
var _chat_handler: ChatHandler

## Cena atual do jogo.
var current_scene: Scene


## Inicializa o cliente e os gerenciadores.
func _init() -> void:
	if not _setup_network():
		return

	if not _setup_handlers():
		return

	Network.connected.connect(_on_connected)
	Network.disconnected.connect(_on_disconnected)


## Configura a conexão de rede.
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


## Configura todos os gerenciadores de handlers.
func _setup_handlers() -> bool:
	_action_handler = ActionHandler.new()
	add_child(_action_handler)

	var action: Error = _action_handler.register()
	if action != OK:
		return false

	_auth_handler = AuthHandler.new()
	add_child(_auth_handler)

	var auth_err: Error = _auth_handler.register()
	if auth_err != OK:
		return false

	_character_handler = CharacterHandler.new()
	add_child(_character_handler)

	var character_err: Error = _character_handler.register()
	if character_err != OK:
		return false

	_map_handler = MapHandler.new()
	add_child(_map_handler)

	var map_err: Error = _map_handler.register()
	if map_err != OK:
		return false

	_chat_handler = ChatHandler.new()
	add_child(_chat_handler)

	var chat_err: Error = _chat_handler.register()
	if chat_err != OK:
		return false

	return true


## Processa a conexão estabelecida com o servidor.
func _on_connected() -> void:
	go_to_menu()


## Processa a desconexão do servidor.
func _on_disconnected() -> void:
	go_to_menu()


## Navega para o menu principal.
func go_to_menu() -> void:
	_change_scene("res://source/scenes/menu/menu.tscn")


## Navega para a cena do jogo.
func go_to_game() -> void:
	_change_scene("res://source/scenes/game/game.tscn")


## Troca a cena atual pela cena informada.
func _change_scene(scene_path: String) -> void:
	var packed: PackedScene = load(scene_path)
	var scene: Node = packed.instantiate()

	if current_scene != null:
		current_scene.queue_free()

	var class_name_str: String = scene.get_script().get_global_name()
	scene.name = class_name_str

	current_scene = scene
	add_child(scene)
