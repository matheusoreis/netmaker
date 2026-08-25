extends Node2D
class_name Main


## Gerencia a comunicação de rede do servidor.
var _network: Network


## Módulos responsáveis pelos dados do servidor.
var _account_module: AccountModule
var _character_module: CharacterModule
var _map_module: MapModule


## Handlers responsáveis pelas operações do servidor.
var _auth_handler: AuthHandler
var _account_handler: AccountHandler
var _map_handler: MapHandler


## Inicializa os módulos e configura a rede.
func _ready() -> void:
	_account_module = AccountModule.new()
	_character_module = CharacterModule.new()
	_map_module = MapModule.new()

	if not _setup_network():
		return

	_network.peer_connected.connect(
		_on_peer_connected
	)

	_network.peer_disconnected.connect(
		_on_peer_disconnected
	)


## Processa os eventos.
func _physics_process(_delta: float) -> void:
	if _network:
		_network.poll()


## Inicializa o servidor de rede.
func _setup_network() -> bool:
	_network = Network.new()

	print("Iniciando servidor em %s:%d (máx. %d peers)..." % [
		Constants.HOST,
		Constants.PORT,
		Constants.MAX_PEERS,
	])

	var err: Error = _network.start(Constants.HOST, Constants.PORT, Constants.MAX_PEERS)
	if err != OK:
		push_error("Erro ao iniciar o servidor (%s)." % error_string(err))
		return false

	print("Servidor iniciado com sucesso!")
	return true


## Inicializa e registra os handlers do servidor.
func _setup_handlers() -> bool:
	_auth_handler = AuthHandler.new(
		_network,
	)

	var auth_err: Error = _auth_handler.register()
	if auth_err != OK:
		return false

	_account_handler = AccountHandler.new(
		_network,
	)

	var account_err: Error = _account_handler.register()
	if account_err != OK:
		return false

	_map_handler = MapHandler.new(
		_network,
	)

	var map_err: Error = _map_handler.register()
	if map_err != OK:
		return false

	return true


## Trata a conexão de um novo peer.
func _on_peer_connected(peer_id: int) -> void:
	print("Peer %d conectado." % peer_id)


## Trata a desconexão de um peer.
func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer %d desconectado." % peer_id)
