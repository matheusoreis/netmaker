extends RefCounted
class_name Network

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

var _client: EnhancedClient


func initialize(address: String, port: int, max_channels: int, max_tasks: int) -> void:
	_client = EnhancedClient.new(max_tasks)

	print("[NETWORK] Conectando em %s:%d..." % [address, port])

	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(
		address,
		port,
		max_channels
	)

	if error != OK:
		push_error("[NETWORK] Falha ao iniciar o network: %s" % error)
		return

	_client.start(peer)
	print("[NETWORK] Network iniciado em %s:%d..." % [address, port])

	_client.connected.connect(
		func():
			print("[NETWORK] Conectado ao servidor.")
			peer_connected.emit(1)
	)

	_client.disconnected.connect(
		func():
			print("[NETWORK] Desconectado do servidor.")
			peer_disconnected.emit(1)
	)

func poll(connection_timeout: int) -> void:
	if _client:
		_client.poll(connection_timeout)
