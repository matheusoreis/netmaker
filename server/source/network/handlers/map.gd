extends RefCounted
class_name MapHandler


var _network: Network


func _init(network: Network) -> void:
	_network = network


func register() -> Error:
	return _network.register([
		map_data,
		enter_map,
		leave_map,
		move_character,
	])


func unregister() -> Error:
	return _network.register([
		map_data,
		enter_map,
		leave_map,
		move_character,
	])


func map_data() -> void:
	var sender_id: int = _network.sender_id()


func enter_map() -> void:
	var sender_id: int = _network.sender_id()


func leave_map() -> void:
	var sender_id: int = _network.sender_id()


func move_character(direction: Vector2i) -> void:
	var sender_id: int = _network.sender_id()
