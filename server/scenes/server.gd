extends Node


func _ready() -> void:
	if not _setup_database():
		return

	if not _setup_network():
		return


func _setup_database() -> bool:
	return OK if Database.create(
		Constants.Server.DATABASE_PATH,
		Constants.Server.DATABASE_FILENAME,
		true
	) else FAILED


func _setup_network() -> bool:
	return true if Network.create_server(
		Constants.Server.NETWORK_PORT,
		Constants.Server.NETWORK_MAX_CLIENTS,
		Constants.Server.NETWORK_MAX_TASKS
	) == OK else false
