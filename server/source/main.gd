extends Node2D
class_name Main


@export_category("Localization")
@export_enum("en_US", "pt_BR") var _language: String = "en_US"

@export_category("Network")
@export_range(1, 65535) var _port: int = 7720
@export_range(1, 4096) var _max_peers: int = 100
@export_range(1, 32) var _max_channels: int = 3
@export_range(0, 60000, 1, "suffix:ms") var _network_poll_time: int = 0
@export_range(1, 10240) var _max_network_tasks: int = 2048

@export_category("Database")
@export_dir var _database_path: String = "user://database/"
@export var _database_filename: String = "server"
@export_range(0, 60000, 1, "suffix:ms") var _database_poll_time: int = 0

var _database: Database
var _network: Network

var _account_repository: AccountRepository
var _character_repository: CharacterRepository
var _map_repository: MapRepository

var _account_cache: AccountCache
var _character_cache: CharacterCache
var _map_cache: MapCache

var _auth_handler: AuthHandler
var _account_handler: AccountHandler
var _map_handler: MapHandler


func _ready() -> void:
	TranslationServer.set_locale(_language)

	if _initialize_database() != OK:
		return

	_initialize_repositories()
	await _initialize_caches()

	_initialize_network()
	_initialize_handlers()


func _initialize_database() -> Error:
	_database = Database.new(_database_path, _database_filename)
	return OK if _database.connection != null else FAILED


func _initialize_repositories() -> void:
	_account_repository = AccountRepository.new(_database.connection)
	_character_repository = CharacterRepository.new(_database.connection)
	_map_repository = MapRepository.new(_database.connection)


func _initialize_caches() -> void:
	_account_cache = AccountCache.new(_account_repository)
	_character_cache = CharacterCache.new(_character_repository)
	_map_cache = MapCache.new(_map_repository)

	await _account_cache.load_all()
	await _character_cache.load_all()
	await _map_cache.load_all()


func _initialize_network() -> void:
	_network = Network.new(_port, _max_peers, _max_channels, _max_network_tasks)


func _initialize_handlers() -> void:
	_auth_handler = AuthHandler.new(_network, "Auth")
	_account_handler = AccountHandler.new(_network, "Account")
	_map_handler = MapHandler.new(_network, "Map")


func _process(_delta: float) -> void:
	if _database:
		_database.poll(_database_poll_time)

	if _network:
		_network.poll(_network_poll_time)
