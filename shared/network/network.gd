extends Node


signal connected()
signal disconnected()

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)


var multiplayer_peer: Rpc


func _process(_delta: float) -> void:
	if multiplayer_peer:
		multiplayer_peer.poll(Constants.Server.NETWORK_POLL_TIME)


func create_server(port: int, max_clients: int, max_tasks: int) -> Error:
	if multiplayer_peer:
		return FAILED

	print("[SERVER] Iniciando servidor...")

	multiplayer_peer = Rpc.Server.new(
		"0.0.0.0", port, max_clients, max_tasks
	)

	print("[SERVER] RPC criado para o servidor!")

	var error: Error = multiplayer_peer.start()
	if error != Error.OK:
		push_error("[SERVER] Falha ao criar servidor. Erro: ", error)
		return error

	print("[SERVER] Servidor criado com sucesso na porta: ", Constants.Server.NETWORK_PORT)
	print("[SERVER] Max clients: ", Constants.Server.NETWORK_MAX_CLIENTS)
	print("[SERVER] Max tasks: ", Constants.Server.NETWORK_MAX_TASKS)

	print("[SERVER] Servidor iniciado com sucesso!")

	_connect_signals()
	return OK


func create_client(address: String, port: int, max_tasks: int) -> Error:
	if multiplayer_peer:
		return FAILED

	print("[CLIENT] Iniciando cliente...")

	print("[CLIENT] RPC criado para o cliente!")

	multiplayer_peer = Rpc.Client.new(
		address, port, max_tasks
	)

	var error: Error = multiplayer_peer.start()
	if error != Error.OK:
		push_error("[CLIENT] Falha ao criar cliente. Erro: ", error)
		return error

	print("[CLIENT] Cliente conectando em: ", Constants.Client.NETWORK_ADDRESS, ":", Constants.Client.NETWORK_PORT)

	print("[CLIENT] Cliente iniciado com sucesso!")

	_connect_signals()
	return OK


func is_server() -> bool:
	return multiplayer_peer is Rpc.Server


func is_client() -> bool:
	return multiplayer_peer is Rpc.Client


func get_peers() -> Array[int]:
	if not is_server():
		return []

	return (multiplayer_peer as Rpc.Server).get_peers()


func get_peer_count() -> int:
	if not is_server():
		return 0

	return (multiplayer_peer as Rpc.Server).get_peer_count()


func has_peer(id: int) -> bool:
	if not is_server():
		return false

	return (multiplayer_peer as Rpc.Server).has_peer(id)


func sender_id() -> int:
	if not is_server():
		return -1

	return (multiplayer_peer as Rpc.Server).sender_id()


func register(scope: StringName, functions: Array[Callable]) -> void:
	if multiplayer_peer:
		multiplayer_peer.register(scope, functions)


func unregister(scope: StringName, functions: Array[Callable]) -> void:
	if multiplayer_peer:
		multiplayer_peer.unregister(scope, functions)


func exec(path: StringName, args: Array = [], target: Variant = -1) -> void:
	if multiplayer_peer == null:
		return

	if multiplayer_peer is Rpc.Client:
		multiplayer_peer.exec(path, args)
	elif multiplayer_peer is Rpc.Server:
		multiplayer_peer.exec(target, path, args)


func invoke(path: StringName, args: Array = [], target: int = -1) -> Variant:
	if multiplayer_peer == null:
		return null

	if multiplayer_peer is Rpc.Client:
		return await multiplayer_peer.invoke(path, args)
	elif multiplayer_peer is Rpc.Server:
		return await multiplayer_peer.invoke(target, path, args)
	return null


func _connect_signals() -> void:
	if multiplayer_peer is Rpc.Server:
		multiplayer_peer.client_connected.connect(_on_peer_connected)
		multiplayer_peer.client_disconnected.connect(_on_peer_disconnected)
	elif multiplayer_peer is Rpc.Client:
		multiplayer_peer.connected.connect(connected.emit)
		multiplayer_peer.disconnected.connect(disconnected.emit)


func _on_peer_connected(peer_id: int) -> void:
	print("[SERVER] Peer conectado: ", peer_id)
	peer_connected.emit(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	print("[SERVER] Peer desconectado: ", peer_id)
	peer_disconnected.emit(peer_id)
