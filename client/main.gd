extends Control


func _ready() -> void:
	if not _setup_database():
		return

	if not _setup_network():
		return


func _setup_database() -> bool:
	return OK if Database.create(
		Constants.Server.DATABASE_PATH,
		Constants.Server.DATABASE_FILENAME,
		false
	) else FAILED


func _setup_network() -> bool:
	return true if Network.create_client(
		Constants.Client.NETWORK_ADDRESS,
		Constants.Client.NETWORK_PORT,
		Constants.Client.NETWORK_MAX_TASKS
	) == OK else false
