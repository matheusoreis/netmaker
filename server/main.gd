extends Node2D
class_name Main


## Gerencia a comunicação com o banco de dados.
var _database: Database

## Gerencia a comunicação de rede do servidor.
var _network: Network

## Repositórios para acesso ao banco de dados.
var _auth_repository: AuthRepository
var _character_repository: CharacterRepository
var _map_repository: MapRepository

## Módulos responsáveis pelos dados do servidor.
var _auth_module: AuthModule
var _character_module: CharacterModule
var _map_module: MapModule

## Serviços responsáveis por orquestrar repositórios e módulos.
var _auth_service: AuthService
var _character_service: CharacterService
var _map_service: MapService

## Handlers responsáveis pelas operações do servidor.
var _auth_handler: AuthHandler
var _character_handler: CharacterHandler
var _map_handler: MapHandler
var _chat_handler: ChatHandler


## Inicializa os módulos e configura a rede.
func _ready() -> void:
	if not await _setup_database():
		return

	_setup_modules()
	_setup_services()

	if not _setup_network():
		return

	if not _setup_handlers():
		return

	await _map_service.load_all_maps()

	_network.peer_connected.connect(_on_peer_connected)
	_network.peer_disconnected.connect(_on_peer_disconnected)


## Processa os eventos.
func _physics_process(_delta: float) -> void:
	if _database:
		_database.poll(Constants.DATABASE_POLL_TIME)

	if _network:
		_network.poll()


## Inicializa o banco de dados.
func _setup_database() -> bool:
	_database = Database.new()

	print("Iniciando banco de dados em %s%s.db" % [
		Constants.DATABASE_PATH,
		Constants.DATABASE_FILENAME
	])

	var err: Error = _database.create(
		Constants.DATABASE_PATH,
		Constants.DATABASE_FILENAME
	)

	if err != OK:
		push_error("Erro ao iniciar o banco de dados (%s)." % error_string(err))
		return false

	_auth_repository = AuthRepository.new()
	await _auth_repository.setup(_database)

	_character_repository = CharacterRepository.new()
	await _character_repository.setup(_database)

	_map_repository = MapRepository.new()
	await _map_repository.setup(_database)

	print("Banco de dados iniciado com sucesso!")
	return true


## Inicializa os módulos responsáveis pelo estado em memória do servidor.
func _setup_modules() -> void:
	_auth_module = AuthModule.new()
	_character_module = CharacterModule.new()
	_map_module = MapModule.new()


## Inicializa os serviços responsáveis por orquestrar repositórios e módulos.
func _setup_services() -> void:
	_auth_service = AuthService.new(_auth_repository, _auth_module)
	_character_service = CharacterService.new(_character_repository, _character_module)
	_map_service = MapService.new(_map_repository, _map_module)


## Inicializa o servidor de rede.
func _setup_network() -> bool:
	_network = Network.new()

	print("Iniciando servidor em %s:%d" % [
		Constants.HOST,
		Constants.PORT,
	])

	var err: Error = _network.start(Constants.HOST, Constants.PORT, Constants.MAX_PEERS)
	if err != OK:
		push_error("Erro ao iniciar o servidor (%s)." % error_string(err))
		return false

	print("Servidor iniciado com sucesso!")
	return true


## Inicializa e registra os handlers do servidor.
func _setup_handlers() -> bool:
	_auth_handler = AuthHandler.new(_network, _auth_service)
	var auth_err: Error = _auth_handler.register()
	if auth_err != OK:
		return false

	_character_handler = CharacterHandler.new(_network, _auth_service, _character_service)
	var character_err: Error = _character_handler.register()
	if character_err != OK:
		return false

	_map_handler = MapHandler.new(_network, _auth_service, _character_service, _map_service)
	var map_err: Error = _map_handler.register()
	if map_err != OK:
		return false

	_chat_handler = ChatHandler.new(_network, _character_service)
	var chat_err: Error = _chat_handler.register()
	if chat_err != OK:
		return false

	return true


## Trata a conexão de um novo peer.
func _on_peer_connected(peer_id: int) -> void:
	print("Peer %d conectado." % peer_id)


## Trata a desconexão de um peer.
func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer %d desconectado." % peer_id)

	_map_handler.leave_map(peer_id)

	await _character_service.unload_character(peer_id)
	await _auth_service.sign_out(peer_id)
