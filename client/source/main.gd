extends Node
class_name Main


@export_category("Configuration")
@export_group("Network")
@export var _address: String = "127.0.0.1"
@export_range(1, 65535) var _port: int = 7720
@export_range(1, 32) var _max_channels: int = 3
@export_range(0, 60000, 1, "suffix:ms") var _connection_poll_time: int = 0
@export_range(1, 10240) var _max_tasks: int = 2048
@export_group("Database")
@export_dir var _database_path: String = "user://client/"
@export var _database_filename: String = "client"
@export_range(0, 60000, 1, "suffix:ms") var _database_poll_time: int = 0

var _database: Database
var _network: Network


func _ready() -> void:
	_database = Database.new()
	_database.initialize(_database_path, _database_filename)

	_network = Network.new()
	_network.initialize(_address, _port, _max_channels, _max_tasks)

	_network.peer_connected.connect(
		_on_connected
	)

	_network.peer_disconnected.connect(
		_on_disconnected
	)


func _process(_delta: float) -> void:
	if _database:
		_database.poll(_database_poll_time)
	if _network:
		_network.poll(_connection_poll_time)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		print("Movendo para cima...")
		_network.exec("game.map.move", func(buf: StreamPeerBuffer) -> void:
			buf.put_8(0)
			buf.put_8(-1)
		)
	elif event.is_action_pressed("ui_down"):
		print("Movendo para baixo...")
		_network.exec("game.map.move", func(buf: StreamPeerBuffer) -> void:
			buf.put_8(0)
			buf.put_8(1)
		)
	elif event.is_action_pressed("ui_left"):
		print("Movendo para esquerda...")
		_network.exec("game.map.move", func(buf: StreamPeerBuffer) -> void:
			buf.put_8(-1)
			buf.put_8(0)
		)
	elif event.is_action_pressed("ui_right"):
		print("Movendo para direita...")
		_network.exec("game.map.move", func(buf: StreamPeerBuffer) -> void:
			buf.put_8(1)
			buf.put_8(0)
		)


func _on_connected(_peer_id: int) -> void:
	print("[CLIENT] Conectado ao servidor! Entrando no mapa...")
	_network.exec("game.map.entered")


func _on_disconnected(_peer_id: int) -> void:
	print("[CLIENT] Desconectado do servidor.")
