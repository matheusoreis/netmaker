extends Node2D


var _network: Rpc.Server


func _ready() -> void:
	_initialize_network()


func _initialize_network() -> void:
	_network = Rpc.Server.new()
	Globals.rpc = _network

	var port: int = Constants.PORT
	var max_peers: int = Constants.MAX_PEERS

	print(
		"[SERVER] Iniciando servidor na porta %d com máximo de %d peers" % [
			port, max_peers
		]
	)

	var error: Error = _network.start(
		port, max_peers
	)

	if error != OK:
		push_error("[SERVER] Falha ao iniciar o servidor: %s" % error)
		return

	print("[SERVER] Servidor iniciado com sucesso na porta %d!" % port)

	for child in %Modules.get_children():
		if child is not RpcModule:
			push_warning("[RPC] Node ignorado não é RpcModule: %s" % child.name)
			continue

		child.initialize(_network)

	_network.client_connected.connect(_peer_connected)
	_network.client_disconnected.connect(_peer_disconnected)


func _peer_connected(pid: int) -> void:
	print("[SERVER] Cliente %d conectado!" % pid)


func _peer_disconnected(pid: int) -> void:
	print("[SERVER] Cliente %d desconectado!" % pid)
