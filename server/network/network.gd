class_name NetworkServer extends RefCounted


signal peer_connected(peer: ENetPacketPeer)
signal peer_disconnected(peer: ENetPacketPeer)


var _enet: ENetConnection
var _handlers: Dictionary

var _peers: Array[ENetPacketPeer]


func start(port: int, capacity: int) -> Error:
	_enet = ENetConnection.new()

	var err := _enet.create_host_bound("0.0.0.0", port, capacity)
	if err != OK:
		print("[SERVER] Erro ao iniciar servidor na porta %d" % port)
		return err

	print("[SERVER] Servidor iniciado na porta %d" % port)
	return OK


func get_peers() -> Array[ENetPacketPeer]:
	return _peers.duplicate()


func register_handlers(handlers: Array) -> void:
	for handler in handlers:
		var id: int = handler[0]

		var callable: Callable = handler[1] as Callable
		if callable.is_valid():
			_handlers[id] = callable

		print("[SERVER] Registrado o handler %s." % str(id))


func process() -> void:
	if _enet == null:
		return

	var event: Array = _enet.service()
	if event.is_empty():
		return

	match event[0]:
		ENetConnection.EventType.EVENT_CONNECT:
			_handle_connect(event[1])
		ENetConnection.EventType.EVENT_DISCONNECT:
			_handle_disconnect(event[1])
		ENetConnection.EventType.EVENT_RECEIVE:
			_handle_packet(event[1])
		ENetConnection.EventType.EVENT_ERROR:
			print("[SERVER] Erro interno de rede.")


func _handle_connect(peer: ENetPacketPeer) -> void:
	_peers.append(peer)
	peer_connected.emit(peer)


func _handle_disconnect(peer: ENetPacketPeer) -> void:
	_peers.erase(peer)
	peer_disconnected.emit(peer)


func _handle_packet(peer: ENetPacketPeer) -> void:
	var packet_data := peer.get_packet()
	if packet_data.is_empty():
		return

	var result = bytes_to_var(packet_data)
	if result == null or typeof(result) != TYPE_ARRAY or result.size() < 2:
		print("[SERVER] Pacote inválido de peer %s" % [str(peer)])
		return

	var id: int = result[0]
	var args: Variant = result[1]

	if not _handlers.has(id):
		print("[SERVER] Nenhum handler registrado para pacote %d" % id)
		return

	var handler: Callable = _handlers[id]
	if not handler.is_valid():
		print("[SERVER] Handler inválido para pacote %d" % id)
		return

	var bound_handler := handler.bind(peer)
	bound_handler.callv(args)
