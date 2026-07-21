extends Node


signal error(code: Error)

signal connected()
signal disconnected()


const PACKET_TY: Array[Variant.Type] = [TYPE_INT, TYPE_ARRAY]

const _SELF_SCOPE: StringName = "Client"
const _REMOTE_SCOPE: StringName = "Server"


var _lookup: Dictionary[int, Array]
var _enet_host: ENetConnection
var _peer: ENetPacketPeer


func _init() -> void:
	_lookup = {}


func register(remote_funcs: Array[Callable]) -> Error:
	for fn: Callable in remote_funcs:
		var fn_name: StringName = fn.get_method()
		if fn_name == '<anonymous lambda>':
			return ERR_INVALID_PARAMETER

		var fn_id: int = ('%s.%s' % [_SELF_SCOPE, fn_name]).hash()
		if _lookup.has(fn_id):
			return ERR_ALREADY_EXISTS

		_lookup[fn_id] = [fn, _get_args_ty(fn.get_object(), fn_name)]
	return OK


func unregister(remote_funcs: Array[Callable]) -> Error:
	for fn: Callable in remote_funcs:
		var fn_id: int = ('%s.%s' % [_SELF_SCOPE, fn.get_method()]).hash()
		if not _lookup.has(fn_id):
			return ERR_DOES_NOT_EXIST
		_lookup.erase(fn_id)
	return OK


func start(address: String, port: int) -> Error:
	_enet_host = ENetConnection.new()
	var err: Error = _enet_host.create_host(1)
	if err != OK:
		return err

	_peer = _enet_host.connect_to_host(address, port)
	if _peer == null:
		return ERR_CANT_CONNECT
	return OK


func stop() -> void:
	_peer.peer_disconnect_later()

	await disconnected

	_enet_host.destroy()
	_enet_host = null


func poll() -> void:
	if _enet_host == null:
		return

	while true:
		var ev: Array = _enet_host.service()
		if ev[0] == ENetConnection.EventType.EVENT_NONE:
			break
		_handle_event(ev)


func exec(fn_path: StringName, args: Array = []) -> Error:
	if _peer == null:
		return ERR_UNCONFIGURED

	var fn_id: int = ('%s.%s' % [_REMOTE_SCOPE, fn_path]).hash()
	_send([fn_id, args])
	return OK


func _get_args_ty(obj: Object, fn_name: StringName) -> Array[Variant.Type]:
	var args: Array[Variant.Type] = []
	for method: Dictionary in obj.get_method_list():
		if method.name == fn_name:
			for arg: Dictionary in method.args:
				args.push_back(arg.type)
	return args


func _handle_event(ev: Array) -> void:
	match ev[0]:
		ENetConnection.EventType.EVENT_ERROR:
			error.emit(FAILED)

		ENetConnection.EventType.EVENT_CONNECT:
			_peer = ev[1]
			connected.emit()

		ENetConnection.EventType.EVENT_DISCONNECT:
			_peer = null
			disconnected.emit()

		ENetConnection.EventType.EVENT_RECEIVE:
			_handle_packet(_peer.get_packet())


func _send(packet: Array) -> void:
	_peer.send(0, var_to_bytes(packet), ENetPacketPeer.FLAG_RELIABLE)


func _validate_args(args_ty: Array[Variant.Type], args: Array) -> Error:
	if args.size() != args_ty.size():
		return ERR_INVALID_PARAMETER

	for i: int in args.size():
		if typeof(args[i]) != args_ty[i]:
			return ERR_INVALID_PARAMETER

	return OK


func _handle_packet(packet_buf: PackedByteArray) -> void:
	var packet_value: Variant = bytes_to_var(packet_buf)
	if packet_value == null:
		return

	var packet: Array = packet_value as Array
	if _validate_args(PACKET_TY, packet) != OK:
		return

	var entry: Variant = _lookup.get(packet[0])
	if entry == null:
		return

	if _validate_args(entry[1], packet[1]) == OK:
		entry[0].callv(packet[1])
