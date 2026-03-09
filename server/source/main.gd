extends Node
class_name Main


@export_category("Configuration")
@export_group("Network")
@export_range(1, 65535) var _port: int = 7720
@export_range(1, 32) var _max_channels: int = 3
@export_range(0, 60000, 1, "suffix:ms") var _connection_poll_time: int = 0
@export_range(1, 4096) var _max_peers: int = 100
@export_range(1, 10240) var _max_tasks: int = 2048
@export_group("Database")
@export_dir var _database_path: String = "user://server/"
@export var _database_filename: String = "server"
@export_range(0, 60000, 1, "suffix:ms") var _database_poll_time: int = 0

@export_category("Caches")
@export_group("Maps")
@export var _map_cache: MapCache

@export_category("Handlers")
@export var _map_handler: MapHandler

var _database: Database
var _network: Network


func _ready() -> void:
	_database = Database.new()
	_database.initialize(
		_database_path,
		_database_filename
	)

	_network = Network.new()
	_network.initialize(
		_port,
		_max_channels,
		_max_peers,
		_max_tasks
	)

	_map_cache.initialize()

	_map_handler.initialize(_network, _map_cache)


func _process(_delta: float) -> void:
	if _database:
		_database.poll(_database_poll_time)
	if _network:
		_network.poll(_connection_poll_time)
