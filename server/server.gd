extends Node


func _ready() -> void:
	if not _setup_database():
		return

	if not _setup_network():
		return


func _setup_database() -> bool:
	return OK if Database.create_database() else FAILED


func _setup_network() -> bool:
	return true if Network.create_server() == OK else false
