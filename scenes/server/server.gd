extends Node2D

@export_category("Connection")
@export var _port: int = 7001
@export var _max_peers: int = 100
@export var _connection_poll_time: int = 1

@export_category("Database")
@export var _db_path: String = "user://server/"
@export var _db_filename: String = "server"
@export var _db_poll_time: int = 1


var _network: Rpc.Server
var _database: Database


func _ready() -> void:
	await _initialize_database()
	_initialize_network()


func _initialize_database() -> void:
	_database = Database.new()

	var conn: AsletConn = _database.initialize(_db_path, _db_filename)
	if conn == null:
		push_error("[APP] Falha ao iniciar banco de dados.")
		return

	for child in %Repositories.get_children():
		if child is not Repository:
			push_warning(
				"[DATABASE] Node ignorado, não é Repository: %s" % child.name
			)
			continue

		var repository := child as Repository
		var err: Error = await repository.initialize(conn)

		if err != OK:
			push_error(
				"[DATABASE] Falha ao iniciar repositório: %s" % repository.name
			)
			return


func _initialize_network() -> void:
	_network = Rpc.Server.new()
	Globals.rpc = _network

	print(
		"[SERVER] Iniciando servidor na porta %d com máximo de %d peers" % [
			_port, _max_peers
		]
	)

	var error: Error = _network.start(
		_port, _max_peers
	)

	if error != OK:
		push_error("[SERVER] Falha ao iniciar o servidor: %s" % error)
		return

	print("[SERVER] Servidor iniciado com sucesso na porta %d!" % _port)

	for child in %Modules.get_children():
		if child is not NetworkModule:
			push_warning("[RPC] Node ignorado não é NetworkModule: %s" % child.name)
			continue

		child.initialize(_network)

	_network.client_connected.connect(_peer_connected)
	_network.client_disconnected.connect(_peer_disconnected)


func _peer_connected(pid: int) -> void:
	print("[SERVER] Cliente %d conectado!" % pid)


func _peer_disconnected(pid: int) -> void:
	print("[SERVER] Cliente %d desconectado!" % pid)


func _process(_delta: float) -> void:
	if _database:
		_database.poll(_db_poll_time)

	if _network:
		_network.poll(_connection_poll_time)
