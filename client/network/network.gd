extends Node
class_name NetworkClient


var _enet: ENetConnection
var _peer: ENetPacketPeer

var _handlers: Dictionary = {}


func start(host: String, port: int) -> Error:
	_enet = ENetConnection.new()

	var err := _enet.create_host()
	if err != OK:
		print("[CLIENT] Erro ao criar host local")
		return err

	_peer = _enet.connect_to_host(host, port)
	if _peer == null:
		print("[CLIENT] Falha ao conectar ao servidor %s:%d" % [host, port])
		return FAILED

	return OK


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
			_handle_connect()
		ENetConnection.EventType.EVENT_DISCONNECT:
			_handle_disconnect()
		ENetConnection.EventType.EVENT_RECEIVE:
			_handle_packet(event[1])
		ENetConnection.EventType.EVENT_ERROR:
			print("[SERVER] Erro interno de rede.")


func _handle_connect() -> void:
	print("[CLIENT] Conectado ao servidor")


func _handle_disconnect() -> void:
	print("[CLIENT] Desconectado do servidor")


func _handle_packet(peer: ENetPacketPeer) -> void:
	var packet_data := peer.get_packet()
	if packet_data.is_empty():
		return

	var result = bytes_to_var(packet_data)
	if result == null or typeof(result) != TYPE_ARRAY or result.size() < 2:
		print("[CLIENT] Pacote inválido")
		return

	var id: int = result[0]
	var args: Variant = result[1]

	if not _handlers.has(id):
		print("[CLIENT] Nenhum handler registrado para pacote %d" % id)
		return

	var handler: Callable = _handlers[id]
	if not handler.is_valid():
		print("[CLIENT] Handler inválido para pacote %d" % id)
		return

	handler.callv(args)
