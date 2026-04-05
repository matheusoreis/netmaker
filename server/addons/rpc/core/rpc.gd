class_name Rpc
extends RefCounted


enum Action  { EXEC, INVOKE, RESULT }
enum Channel { RELIABLE = 0, UNRELIABLE = 1 }


var _lookup: Dictionary[int, Array]
var _tasks:  Array[Task]


func _init(max_tasks: int) -> void:
	_lookup = {}
	_tasks  = []
	_tasks.resize(max_tasks)


func register(name: StringName, remote_funcs: Array[Callable]) -> void:
	for fn: Callable in remote_funcs:
		var fn_name: StringName = fn.get_method()
		if fn_name == &'<anonymous lambda>':
			continue

		var id: int = ('%s.%s' % [name, fn_name]).hash()
		if _lookup.has(id):
			continue

		_lookup[id] = [fn, _get_args_ty(fn.get_object(), fn_name)]


func unregister(name: StringName, remote_funcs: Array[Callable]) -> void:
	for fn: Callable in remote_funcs:
		var id: int = ('%s.%s' % [name, fn.get_method()]).hash()
		_lookup.erase(id)


func _get_args_ty(obj: Object, fn_name: StringName) -> Array[Variant.Type]:
	var args: Array[Variant.Type] = []
	for method: Dictionary in obj.get_method_list():
		if method.name == fn_name:
			for arg: Dictionary in method.args:
				args.push_back(arg.type as Variant.Type)
	return args


class Task extends RefCounted:
	signal done(value: Variant)


# ─── Client ────────────────────────────────────────────────────────────────────

class Client extends Rpc:
	signal connected
	signal disconnected
	signal connection_failed


	var _peer: MultiplayerPeer


	func _init(peer: MultiplayerPeer, max_tasks: int = 1024) -> void:
		super(max_tasks)
		_peer = peer
		_peer.peer_connected.connect(_on_connected)
		_peer.peer_disconnected.connect(_on_disconnected)


	func stop() -> void:
		if _peer == null: return
		_peer.close()
		_peer = null


	func poll(timeout_ms: int = 0) -> void:
		if _peer == null: return
		var start: int = Time.get_ticks_msec()
		_poll_events()
		while Time.get_ticks_msec() - start < timeout_ms:
			if _peer == null: return
			_poll_events()


	func exec(fn_path: StringName, args: Array = [], channel: Channel = Channel.RELIABLE) -> void:
		_send_packet([Action.EXEC, fn_path.hash(), args], channel)


	func invoke(fn_path: StringName, args: Array = [], channel: Channel = Channel.RELIABLE) -> Variant:
		var task_id: int = _tasks.find(null)
		assert(task_id != -1, "[rpc] task pool exhausted")

		var task: Task = Task.new()
		_tasks[task_id] = task

		_send_packet([Action.INVOKE, fn_path.hash(), args, task_id], channel)

		var result: Variant = await task.done
		_tasks[task_id] = null
		return result


	func _on_connected(_id: int) -> void:
		connected.emit()


	func _on_disconnected(_id: int) -> void:
		disconnected.emit()


	func _poll_events() -> void:
		if _peer == null: return
		_peer.poll()

		while _peer.get_available_packet_count() > 0:
			_handle_packet(_peer.get_packet())


	func _send_packet(packet: Array, channel: Channel) -> void:
		_peer.set_transfer_channel(channel as int)
		_peer.set_transfer_mode(
			MultiplayerPeer.TRANSFER_MODE_RELIABLE
			if channel == Channel.RELIABLE
			else MultiplayerPeer.TRANSFER_MODE_UNRELIABLE
		)
		_peer.put_packet(var_to_bytes(packet))


	func _handle_packet(packet_buf: PackedByteArray) -> void:
		var raw: Variant = bytes_to_var(packet_buf)
		if raw == null:
			push_error("[rpc] received null packet")
			return

		var packet: Array = raw as Array
		if packet == null || packet.size() < 2:
			push_error("[rpc] received malformed packet")
			return

		match packet[0] as Action:
			Action.EXEC:            # [action, hash, args]
				var fn_entry: Array = _lookup.get(packet[1] as int, []) as Array
				if fn_entry.is_empty(): return
				(fn_entry[0] as Callable).callv(packet[2] as Array)

			Action.INVOKE:          # [action, hash, args, task_id]
				var fn_entry: Array = _lookup.get(packet[1] as int, []) as Array
				if fn_entry.is_empty(): return
				var result: Variant = await (fn_entry[0] as Callable).callv(packet[2] as Array)
				_send_packet([Action.RESULT, result, packet[3] as int], Channel.RELIABLE)

			Action.RESULT:          # [action, value, task_id]
				var task_id: int = packet[2] as int
				var task: Task   = _tasks[task_id]
				if task == null: return
				task.done.emit(packet[1])


# ─── Server ────────────────────────────────────────────────────────────────────

class Server extends Rpc:
	signal client_connected(id: int)
	signal client_disconnected(id: int)


	var _peer:      MultiplayerPeer
	var _sender_id: int = 0


	func _init(peer: MultiplayerPeer, max_tasks: int = 1024) -> void:
		super(max_tasks)
		_peer = peer
		_peer.peer_connected.connect(_on_client_connected)
		_peer.peer_disconnected.connect(_on_client_disconnected)


	func stop() -> void:
		if _peer == null: return
		_peer.close()
		_peer = null


	func poll(timeout_ms: int = 0) -> void:
		if _peer == null: return
		var start: int = Time.get_ticks_msec()
		_poll_events()
		while Time.get_ticks_msec() - start < timeout_ms:
			_poll_events()


	# target pode ser: int (peer id), Array[int] (lista), Callable (filtro), ou TARGET_PEER_BROADCAST (-1)
	func exec(target: Variant, fn_path: StringName, args: Array = [], channel: Channel = Channel.RELIABLE) -> void:
		_send_to_target(target, [Action.EXEC, fn_path.hash(), args], channel)


	func invoke(target: int, fn_path: StringName, args: Array = [], channel: Channel = Channel.RELIABLE) -> Variant:
		var task_id: int = _tasks.find(null)
		assert(task_id != -1, "[rpc] task pool exhausted")

		var task: Task = Task.new()
		_tasks[task_id] = task

		_send_to_peer(target, [Action.INVOKE, fn_path.hash(), args, task_id], channel)

		var result: Variant = await task.done
		_tasks[task_id] = null
		return result


	func sender_id() -> int:
		return _sender_id


	func _on_client_connected(id: int) -> void:
		client_connected.emit(id)


	func _on_client_disconnected(id: int) -> void:
		client_disconnected.emit(id)


	func _poll_events() -> void:
		if _peer == null: return
		_peer.poll()

		while _peer.get_available_packet_count() > 0:
			_sender_id = _peer.get_packet_peer()
			_handle_packet(_sender_id, _peer.get_packet())


	func _kick(client_id: int) -> void:
		_peer.disconnect_peer(client_id)


	func _send_to_peer(target_id: int, packet: Array, channel: Channel) -> void:
		_peer.set_target_peer(target_id)
		_peer.set_transfer_channel(channel as int)
		_peer.set_transfer_mode(
			MultiplayerPeer.TRANSFER_MODE_RELIABLE
			if channel == Channel.RELIABLE
			else MultiplayerPeer.TRANSFER_MODE_UNRELIABLE
		)
		_peer.put_packet(var_to_bytes(packet))


	func _send_to_target(target: Variant, packet: Array, channel: Channel) -> void:
		match typeof(target):
			TYPE_INT:
				_send_to_peer(target as int, packet, channel)
			TYPE_ARRAY:
				for id: int in (target as Array):
					_send_to_peer(id, packet, channel)
			TYPE_CALLABLE:
				for id: int in _peer.get_peer_ids():
					if (target as Callable).call(id) as bool:
						_send_to_peer(id, packet, channel)


	func _validate_args(args_ty: Array[Variant.Type], args: Array) -> bool:
		if args.size() != args_ty.size():
			return false
		for i: int in args.size():
			if typeof(args[i]) != args_ty[i]:
				return false
		return true


	func _handle_packet(client_id: int, packet_buf: PackedByteArray) -> void:
		var raw: Variant = bytes_to_var(packet_buf)
		if raw == null:
			_kick(client_id)
			return

		var packet: Array = raw as Array
		if packet == null || packet.size() < 3:
			_kick(client_id)
			return

		match packet[0] as Action:
			Action.EXEC:            # [action, hash, args]
				if typeof(packet[1]) != TYPE_INT || typeof(packet[2]) != TYPE_ARRAY:
					_kick(client_id)
					return

				var fn_entry: Array = _lookup.get(packet[1] as int, []) as Array
				if fn_entry.is_empty():
					_kick(client_id)
					return

				if _validate_args(fn_entry[1] as Array[Variant.Type], packet[2] as Array):
					(fn_entry[0] as Callable).callv(packet[2] as Array)
				else:
					_kick(client_id)

			Action.INVOKE:          # [action, hash, args, task_id]
				if packet.size() < 4 || typeof(packet[1]) != TYPE_INT || typeof(packet[2]) != TYPE_ARRAY || typeof(packet[3]) != TYPE_INT:
					_kick(client_id)
					return

				var fn_entry: Array = _lookup.get(packet[1] as int, []) as Array
				if fn_entry.is_empty():
					_kick(client_id)
					return

				if _validate_args(fn_entry[1] as Array[Variant.Type], packet[2] as Array):
					var result: Variant = await (fn_entry[0] as Callable).callv(packet[2] as Array)
					_send_to_peer(client_id, [Action.RESULT, result, packet[3] as int], Channel.RELIABLE)
				else:
					_kick(client_id)

			Action.RESULT:          # [action, value, task_id]
				if packet.size() < 3 || typeof(packet[2]) != TYPE_INT:
					_kick(client_id)
					return

				var task_id: int = packet[2] as int
				var task: Task   = _tasks[task_id]
				if task == null:
					_kick(client_id)
					return

				task.done.emit(packet[1])

			_:
				_kick(client_id)
