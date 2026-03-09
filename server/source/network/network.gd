extends RefCounted
class_name Network

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

var _server: EnhancedServer


func initialize(port: int, max_channels: int, max_peers: int, max_tasks: int) -> void:
	_server = EnhancedServer.new(max_tasks)

	print("[NETWORK] Iniciando o network na porta %d..." % port)

	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(
		port,
		max_peers,
		max_channels
	)

	if error != OK:
		push_error("[NETWORK] Falha ao iniciar o network: %s" % error)
		return

	_server.start(peer)
	print("[NETWORK] Network iniciado com capacidade de %d peers." % max_peers)

	_server.peer_connected.connect(
		func(peer_id: int):
			print("[NETWORK] Novo peer conectado: %d" % peer_id)
			peer_connected.emit(peer_id)
	)

	_server.peer_disconnected.connect(
		func(peer_id: int):
			print("[NETWORK] Peer desconectado: %d" % peer_id)
			peer_disconnected.emit(peer_id)
	)


func register(scope: StringName, functions: Array[Callable]) -> void:
	if _server:
		_server.register_methods(scope, functions)


func unregister(scope: StringName, functions: Array[Callable]) -> void:
	if _server:
		_server.unregister_methods(scope, functions)


func exec(target: Variant, path: StringName, writer: Callable = Callable(), channel: int = 0) -> void:
	if _server:
		_server.exec(target, path, writer, channel)


func invoke(peer_id: int, path: StringName, writer: Callable = Callable(), channel: int = 0) -> StreamPeerBuffer:
	if _server:
		return await _server.invoke(peer_id, path, writer, channel)
	return null


func poll(_connection_timeout: int) -> void:
	if _server:
		_server.poll(_connection_timeout)
