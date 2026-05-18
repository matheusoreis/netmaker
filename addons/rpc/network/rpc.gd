class_name Rpc
extends RefCounted


enum { EXEC, INVOKE, RESULT }


const EXEC_PACKET_TY: Array[Variant.Type] = [TYPE_INT, TYPE_INT, TYPE_ARRAY]
const INVOKE_PACKET_TY: Array[Variant.Type] = [TYPE_INT, TYPE_INT, TYPE_ARRAY, TYPE_INT]


var _lookup: Dictionary[int, Array]
var _tasks: Array
var _max_tasks: int


func _init(max_tasks: int) -> void:
	_max_tasks = max_tasks
	_lookup = {}
	_tasks = []
	_tasks.resize(_max_tasks)


func register(name: StringName, remote_funcs: Array[Callable]) -> Error:
	for fn: Callable in remote_funcs:
		var fn_name: StringName = fn.get_method()
		if fn_name == '<anonymous lambda>':
			return ERR_INVALID_PARAMETER

		var id: int = ('%s.%s' % [name, fn_name]).hash()
		if _lookup.has(id):
			return ERR_ALREADY_EXISTS

		_lookup[id] = [fn, _get_args_ty(fn.get_object(), fn_name)]

	return OK


func unregister(name: StringName, remote_funcs: Array[Callable]) -> void:
	for fn: Callable in remote_funcs:
		var id: int = ('%s.%s' % [name, fn.get_method()]).hash()
		_lookup.erase(id)


@warning_ignore('unused_parameter')
func poll(timeout_ms: int = 0) -> void:
	pass


func _get_args_ty(obj: Object, fn_name: StringName) -> Array[Variant.Type]:
	var args: Array[Variant.Type] = []
	for method: Dictionary in obj.get_method_list():
		if method.name == fn_name:
			for arg: Dictionary in method.args:
				args.push_back(arg.type)
	return args


class Task extends RefCounted:
	@warning_ignore('unused_signal')
	signal done(value: Variant)


class Client extends Rpc:
	signal error(code: Error)
	signal connected
	signal disconnected


	var _enet_host: ENetConnection
	var _peer: ENetPacketPeer
	var _host: String
	var _port: int


	func _init(host: String, port: int, max_tasks: int = 1024) -> void:
		super(max_tasks)
		_host = host
		_port = port


	func start() -> Error:
		_enet_host = ENetConnection.new()
		var err: Error = _enet_host.create_host(1)
		if err != OK:
			return err

		_peer = _enet_host.connect_to_host(_host, _port)
		if _peer == null:
			return ERR_CANT_CONNECT

		return OK


	func stop() -> void:
		_peer.peer_disconnect_later()
		await disconnected
		_enet_host.destroy()
		_enet_host = null


	func poll(timeout_ms: int = 0) -> void:
		if _enet_host == null:
			return
		var st: int = Time.get_ticks_msec()
		_poll_events()
		while Time.get_ticks_msec() - st < timeout_ms:
			if _enet_host == null:
				return
			_poll_events()


	func exec(fn_path: StringName, args: Array = []) -> Error:
		if _peer == null:
			return ERR_UNCONFIGURED
		_send([EXEC, fn_path.hash(), args])
		return OK


	func invoke(fn_path: StringName, args: Array = []) -> Variant:
		var task_id: int = _tasks.find(null)
		if task_id == -1:
			return null

		var task: Task = Task.new()
		_tasks[task_id] = task

		_send([INVOKE, fn_path.hash(), args, task_id])

		var result: Variant = await task.done
		_tasks[task_id] = null
		return result


	func _poll_events() -> void:
		var ev: Array = _enet_host.service()
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


	func _handle_packet(packet_buf: PackedByteArray) -> void:
		var packet: Array = bytes_to_var(packet_buf) as Array
		if packet == null:
			return

		match packet[0]:
			EXEC:
				_lookup[packet[1]][0].callv(packet[2])
			INVOKE:
				_send([RESULT, await _lookup[packet[1]][0].callv(packet[2]), packet[3]])
			RESULT:
				_tasks[packet[2]].done.emit(packet[1])


class Server extends Rpc:
	signal error(code: Error)
	signal client_connected(id: int)
	signal client_disconnected(id: int)


	var _enet_host: ENetConnection
	var _host: String
	var _port: int
	var _max_clients: int
	var _peers: Dictionary[int, ENetPacketPeer]
	var _sender_id: int
	var _next_id: int


	func _init(host: String, port: int, max_clients: int, max_tasks: int = 1024) -> void:
		super(max_tasks)
		_peers = {}
		_host = host
		_port = port
		_max_clients = max_clients
		_next_id = 0


	func start() -> Error:
		_enet_host = ENetConnection.new()
		var err: Error = _enet_host.create_host_bound(_host, _port, _max_clients)
		if err != OK:
			return err
		return OK


	func stop() -> void:
		_enet_host.flush()
		_enet_host.destroy()
		_enet_host = null


	func poll(timeout_ms: int = 0) -> void:
		if _enet_host == null:
			return
		var st: int = Time.get_ticks_msec()
		_poll_events()
		while Time.get_ticks_msec() - st < timeout_ms:
			_poll_events()


	func exec(target: Variant, fn_path: StringName, args: Array = []) -> Error:
		return _send(target, [EXEC, fn_path.hash(), args])


	func invoke(target: Variant, fn_path: StringName, args: Array = []) -> Variant:
		var task_id: int = _tasks.find(null)
		if task_id == -1:
			return null

		var task: Task = Task.new()
		_tasks[task_id] = task

		_send(target, [INVOKE, fn_path.hash(), args, task_id])

		var result: Variant = await task.done
		_tasks[task_id] = null
		return result


	func get_clients() -> Array[int]:
		return _peers.keys()


	func get_client_count() -> int:
		return _peers.size()


	func has_client(id: int) -> bool:
		return _peers.has(id)


	func sender_id() -> int:
		return _sender_id


	func _poll_events() -> void:
		var ev: Array = _enet_host.service()
		match ev[0]:
			ENetConnection.EventType.EVENT_ERROR:
				error.emit(FAILED)
			ENetConnection.EventType.EVENT_CONNECT:
				var peer: ENetPacketPeer = ev[1] as ENetPacketPeer
				var id: int = _next_id
				peer.set_meta('conn_id', id)
				_peers[id] = peer
				_next_id += 1
				client_connected.emit(id)
			ENetConnection.EventType.EVENT_DISCONNECT:
				var peer: ENetPacketPeer = ev[1] as ENetPacketPeer
				var id: int = peer.get_meta('conn_id') as int
				_peers.erase(id)
				client_disconnected.emit(id)
			ENetConnection.EventType.EVENT_RECEIVE:
				var peer: ENetPacketPeer = ev[1] as ENetPacketPeer
				_sender_id = peer.get_meta('conn_id') as int
				_handle_packet(_sender_id, peer.get_packet())


	func _kick(client_id: int, reason: Error) -> void:
		var peer: ENetPacketPeer = _peers.get(client_id)
		if peer == null:
			return
		peer.peer_disconnect()


	func _send(target: Variant, packet: Array) -> Error:
		var packet_buf: PackedByteArray = var_to_bytes(packet)
		match typeof(target):
			TYPE_INT:
				var peer: ENetPacketPeer = _peers.get(target) as ENetPacketPeer
				if peer == null:
					return ERR_DOES_NOT_EXIST
				peer.send(0, packet_buf, ENetPacketPeer.FLAG_RELIABLE)
				return OK
			TYPE_CALLABLE:
				for id: int in _peers:
					if (target as Callable).call(id):
						_peers[id].send(0, packet_buf, ENetPacketPeer.FLAG_RELIABLE)
				return OK
			TYPE_ARRAY:
				var had_missing := false
				for id: int in target:
					var peer: ENetPacketPeer = _peers.get(id) as ENetPacketPeer
					if peer != null:
						peer.send(0, packet_buf, ENetPacketPeer.FLAG_RELIABLE)
					else:
						had_missing = true
				return ERR_DOES_NOT_EXIST if had_missing else OK
			_:
				return ERR_INVALID_PARAMETER


	func _validate_args(args_ty: Array[Variant.Type], args: Array) -> Error:
		if args.size() != args_ty.size():
			return ERR_INVALID_PARAMETER

		for i: int in args.size():
			if typeof(args[i]) != args_ty[i]:
				return ERR_INVALID_PARAMETER

		return OK


	func _handle_packet(client_id: int, packet_buf: PackedByteArray) -> void:
		var packet_value: Variant = bytes_to_var(packet_buf)
		if packet_value == null:
			_kick(client_id, ERR_INVALID_DATA)
			return

		var packet: Array = packet_value as Array
		if packet.size() < 3:
			_kick(client_id, ERR_INVALID_DATA)
			return

		match packet[0]:
			EXEC:
				if _validate_args(EXEC_PACKET_TY, packet) != OK:
					_kick(client_id, ERR_INVALID_DATA)
					return

				var value: Variant = _lookup.get(packet[1])
				if value == null:
					_kick(client_id, ERR_METHOD_NOT_FOUND)
					return

				if _validate_args(value[1], packet[2]) == OK:
					value[0].callv(packet[2])
					return

				_kick(client_id, ERR_INVALID_PARAMETER)

			INVOKE:
				if _validate_args(INVOKE_PACKET_TY, packet) != OK:
					_kick(client_id, ERR_INVALID_DATA)
					return

				var value: Variant = _lookup.get(packet[1])
				if value == null:
					_kick(client_id, ERR_METHOD_NOT_FOUND)
					return

				if _validate_args(value[1], packet[2]) == OK:
					_send(client_id, [RESULT, await value[0].callv(packet[2]), packet[3]])
					return

				_kick(client_id, ERR_INVALID_PARAMETER)

			RESULT:
				if typeof(packet[0]) != TYPE_INT || typeof(packet[2]) != TYPE_INT:
					_kick(client_id, ERR_INVALID_DATA)
					return

				if _tasks[packet[2]] == null:
					_kick(client_id, ERR_INVALID_DATA)
					return

				_tasks[packet[2]].done.emit(packet[1])

			_:
				_kick(client_id, ERR_INVALID_DATA)
