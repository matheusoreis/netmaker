extends RefCounted
class_name AccountHandler


var _network: Network


func _init(network: Network) -> void:
	_network = network


func register() -> Error:
	return _network.register([

	])


func unregister() -> Error:
	return _network.register([

	])
