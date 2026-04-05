extends RefCounted
class_name Handler


var _network: Network
var _scope: StringName


func _init(network: Network, scope: StringName) -> void:
	_network = network
	_scope = scope

	print(tr("NETWORK_HANDLER_STARTING") % _scope.to_upper())

	_network.register(_scope, _methods())

	print(tr("NETWORK_HANDLER_STARTED") % _scope.to_upper())


func _methods() -> Array[Callable]:
	return []


func _sender_id() -> int:
	return _network.get_sender_id()


func _exec(target: Variant, event: StringName, args: Array = [], channel_id: int = 0) -> void:
	_network.exec(target, "%s.%s" % [_scope, event], args, channel_id)


func _invoke(target: int, event: StringName, args: Array = [], channel_id: int = 0) -> Variant:
	return await _network.invoke(target, "%s.%s" % [_scope, event], args, channel_id)
