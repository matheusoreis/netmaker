extends RefCounted
class_name Rpc

enum Type { EXEC, INVOKE, RESULT }

const MAX_TASKS: int = 1024

var _methods: Dictionary = {}
var _pending_tasks: Array = []

var _enet: ENetConnection = null


func _init() -> void:
	_pending_tasks.resize(MAX_TASKS)
	_pending_tasks.fill(null)


func register(scope: StringName, callables: Array[Callable]) -> void:
	for fn in callables:
		var method_name: StringName = fn.get_method()
		if method_name == &"<anonymous lambda>":
			continue

		var path: String = "%s.%s" % [scope, method_name]
		var hash_id: int = path.hash()

		if _methods.has(hash_id):
			continue

		var argument_types: Array = _get_method_argument_types(
			fn.get_object(), method_name
		)

		_methods[hash_id] = [fn, argument_types]


func poll(timeout_ms: int = 0) -> void:
	if not _enet:
		return

	var start_time: int = Time.get_ticks_msec()

	_poll_events()

	while (Time.get_ticks_msec() - start_time) < timeout_ms:
		_poll_events()


func _poll_events() -> void:
	var event: Array = _enet.service()
	if event[0] == ENetConnection.EVENT_NONE:
		return

	_handle_event(event)


func _handle_event(_event: Array) -> void:
	pass


func _get_method_argument_types(source: Object, method_name: StringName) -> Array:
	if not source:
		return []

	for method in source.get_method_list():
		if method.name == method_name:
			var types: Array = []
			for arg in method.args:
				types.push_back(arg.type)
			return types

	return []


func _validate_arguments(hash_id: int, args: Array) -> bool:
	if not _methods.has(hash_id):
		return false

	var expected_types: Array = _methods[hash_id][1]

	if args.size() != expected_types.size():
		return false

	for i: int in range(args.size()):
		if typeof(args[i]) != expected_types[i]:
			return false

	return true


func _handle_rpc_exec(hash_id: int, args: Array) -> void:
	if _validate_arguments(hash_id, args):
		var fn: Callable = _methods[hash_id][0]
		fn.callv(args)


func _handle_rpc_result(result: Variant, task_id: int) -> void:
	if task_id >= 0 and task_id < MAX_TASKS and _pending_tasks[task_id]:
		var task: RpcTask = _pending_tasks[task_id]
		task.done.emit(result)


class Server extends Rpc:
	signal client_connected(peer_id: int)
	signal client_disconnected(peer_id: int)

	var _peers: Array[ENetPacketPeer] = []
	var _sender_id: int = -1


	func start(port: int, max_clients: int = 100) -> Error:
		_enet = ENetConnection.new()

		_peers.resize(max_clients)
		_peers.fill(null)

		return _enet.create_host_bound("0.0.0.0", port, max_clients)


	func exec(peer_id: int, path: String, args: Array = []) -> void:
		_send(peer_id, [Type.EXEC, path.hash(), args])


	func invoke(peer_id: int, path: String, args: Array = []) -> Variant:
		var task_id: int = _pending_tasks.find(null)
		if task_id == -1:
			return null

		var task: RpcTask = RpcTask.new()
		_pending_tasks[task_id] = task

		_send(peer_id, [Type.INVOKE, path.hash(), args, task_id])

		var result: Variant = await task.done
		_pending_tasks[task_id] = null

		return result


	func send_to_many(peer_ids: Array, path: String, args: Array = []) -> void:
		var packet: Array = [Type.EXEC, path.hash(), args]
		var data: PackedByteArray = var_to_bytes(packet)

		for id in peer_ids:
			if id >= 0 and id < _peers.size() and _peers[id]:
				_peers[id].send(0, data, ENetPacketPeer.FLAG_RELIABLE)


	func kick(peer_id: int) -> void:
		if peer_id >= 0 and peer_id < _peers.size() and _peers[peer_id]:
			_peers[peer_id].peer_disconnect()


	func get_sender_id() -> int:
		return _sender_id


	func _handle_event(event: Array) -> void:
		var type: ENetConnection.EventType = event[0]
		var peer: ENetPacketPeer = event[1]

		match type:
			ENetConnection.EVENT_CONNECT:
				var id: int = _get_free_id()
				if id != -1:
					_peers[id] = peer
					peer.set_meta(&"peer_id", id)
					client_connected.emit(id)

			ENetConnection.EVENT_DISCONNECT:
				if peer.has_meta(&"peer_id"):
					var id: int = peer.get_meta(&"peer_id")
					_peers[id] = null
					client_disconnected.emit(id)

			ENetConnection.EVENT_RECEIVE:
				_process_packet(peer)


	func _process_packet(peer: ENetPacketPeer) -> void:
		var peer_id: int = peer.get_meta(&"peer_id")
		var raw_data: Variant = bytes_to_var(peer.get_packet())
		if typeof(raw_data) != TYPE_ARRAY: return

		_sender_id = peer_id

		var packet: Array = raw_data
		var type: int = packet[0]
		var hash_id: int = packet[1]

		match type:
			Type.EXEC:
				_handle_rpc_exec(hash_id, packet[2])
			Type.INVOKE:
				if _validate_arguments(hash_id, packet[2]):
					var res: Variant = await _methods[hash_id][0].callv(packet[2])
					_send(peer_id, [Type.RESULT, res, packet[3]])
			Type.RESULT:
				_handle_rpc_result(packet[1], packet[2])
		_sender_id = -1


	func _send(peer_id: int, data: Array) -> void:
		if peer_id >= 0 and peer_id < _peers.size() and _peers[peer_id]:
			_peers[peer_id].send(0, var_to_bytes(data), ENetPacketPeer.FLAG_RELIABLE)


	func _get_free_id() -> int:
		for i: int in range(_peers.size()):
			if _peers[i] == null: return i
		return -1


class Client extends Rpc:
	signal connected
	signal disconnected

	var _server_peer: ENetPacketPeer = null


	func start(address: String, port: int) -> Error:
		_enet = ENetConnection.new()

		var err: Error = _enet.create_host(1)
		if err != OK:
			return err

		_server_peer = _enet.connect_to_host(address, port)
		return OK if _server_peer else ERR_CANT_CONNECT


	func exec(path: String, args: Array = []) -> void:
		_send([Type.EXEC, path.hash(), args])


	func invoke(path: String, args: Array = []) -> Variant:
		var task_id: int = _pending_tasks.find(null)
		if task_id == -1:
			return null

		var task: RpcTask = RpcTask.new()
		_pending_tasks[task_id] = task

		_send([Type.INVOKE, path.hash(), args, task_id])

		var result: Variant = await task.done
		_pending_tasks[task_id] = null

		return result


	func _handle_event(event: Array) -> void:
		var type: ENetConnection.EventType = event[0]
		match type:
			ENetConnection.EVENT_CONNECT: connected.emit()
			ENetConnection.EVENT_DISCONNECT: disconnected.emit()
			ENetConnection.EVENT_RECEIVE: _process_packet(event[1])


	func _process_packet(peer: ENetPacketPeer) -> void:
		var raw_data: Variant = bytes_to_var(peer.get_packet())
		if typeof(raw_data) != TYPE_ARRAY:
			return

		var packet: Array = raw_data
		var type: int = packet[0]
		var hash_id: int = packet[1]

		match type:
			Type.EXEC:
				_handle_rpc_exec(hash_id, packet[2])
			Type.INVOKE:
				if _validate_arguments(hash_id, packet[2]):
					var res: Variant = await _methods[hash_id][0].callv(packet[2])
					_send([Type.RESULT, res, packet[3]])
			Type.RESULT:
				_handle_rpc_result(packet[1], packet[2])


	func _send(data: Array) -> void:
		if _server_peer:
			_server_peer.send(0, var_to_bytes(data), ENetPacketPeer.FLAG_RELIABLE)


class RpcTask extends RefCounted:
	@warning_ignore("unused_signal")
	signal done(value: Variant)
