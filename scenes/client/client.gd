extends Node2D

@export_category("Connection")
@export var _address: String = "127.0.0.1"
@export var _port: int = 7001


var _network: Rpc.Client


func _ready() -> void:
	_initialize_network()


func _initialize_network() -> void:
	_network = Rpc.Client.new()
	Globals.rpc = _network

	print(
		"[CLIENT] Iniciando cliente em %s:%d" % [
			_address, _port
		]
	)

	var error: Error = _network.start(
		_address, _port
	)

	if error != OK:
		push_error("[CLIENT] Falha ao iniciar o cliente: %s" % error)
		return

	print("[CLIENT] Cliente iniciado com sucesso na porta %d!" % _port)

	for child in %Modules.get_children():
		if child is not RpcModule:
			push_warning("[RPC] Node ignorado não é RpcModule: %s" % child.name)
			continue

		child.initialize(_network)

	_network.connected.connect(_on_connected)
	_network.disconnected.connect(_on_disconnected)


func _on_connected() -> void:
	print("[CLIENT] Conectado ao servidor com sucesso!")


func _on_disconnected() -> void:
	print("[CLIENT] Desconectado do servidor.")
