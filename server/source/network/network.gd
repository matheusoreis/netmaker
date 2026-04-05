extends RefCounted
class_name Network


signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)


var _rpc: Rpc.Server


func _init(port: int, max_peers: int, max_channels: int, max_tasks: int = 1024) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

	print(tr("NETWORK_STARTING") % port)

	var err: Error = peer.create_server(port, max_peers, max_channels)
	if err != OK:
		push_error(tr("NETWORK_START_FAILED") % error_string(err))
		return

	_rpc = Rpc.Server.new(peer, max_tasks)

	_rpc.client_connected.connect(func(id: int) -> void:
		print(tr("NETWORK_PEER_CONNECTED") % id)
		peer_connected.emit(id)
	)

	_rpc.client_disconnected.connect(func(id: int) -> void:
		print(tr("NETWORK_PEER_DISCONNECTED") % id)
		peer_disconnected.emit(id)
	)

	print(tr("NETWORK_STARTED") % max_peers)


func register(scope: StringName, functions: Array[Callable]) -> void:
	if _rpc:
		_rpc.register(scope, functions)


func unregister(scope: StringName, functions: Array[Callable]) -> void:
	if _rpc:
		_rpc.unregister(scope, functions)


func sender_id() -> int:
	if _rpc:
		return _rpc.sender_id()
	return -1


func exec(target: Variant, path: StringName, args: Array = [], channel: Rpc.Channel = Rpc.Channel.RELIABLE) -> void:
	if _rpc:
		_rpc.exec(target, path, args, channel)


func invoke(target: int, path: StringName, args: Array = [], channel: Rpc.Channel = Rpc.Channel.RELIABLE) -> Variant:
	if _rpc:
		return await _rpc.invoke(target, path, args, channel)
	return null


func poll(timeout_ms: int = 0) -> void:
	if _rpc:
		_rpc.poll(timeout_ms)
