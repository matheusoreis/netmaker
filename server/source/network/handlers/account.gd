extends RefCounted
class_name AccountHandler


var _network: Network


func _init(network: Network) -> void:
	_network = network


func register() -> Error:
	return _network.register([
		create_character,
		delete_character,
		select_character
	])


func unregister() -> Error:
	return _network.register([
		create_character,
		delete_character,
		select_character
	])


func list_characters() -> void:
	var sender_id: int = _network.sender_id()


func create_character(identifier: String, spritesheet: String) -> void:
	var sender_id: int = _network.sender_id()


func delete_character(character_id: int) -> void:
	var sender_id: int = _network.sender_id()


func select_character(character_id: int) -> void:
	var sender_id: int = _network.sender_id()
