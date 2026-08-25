extends RefCounted
class_name AuthHandler


var _network: Network


func _init(network: Network) -> void:
	_network = network


func register() -> Error:
	return _network.register([
		sign_in,
		sign_up
	])


func unregister() -> Error:
	return _network.register([
		sign_in,
		sign_up
	])


func sign_in(email: String, password: String, major_version: int, minor_version: int, revision_version: int) -> void:
	var sender_id: int = _network.sender_id()

	if not _is_valid_version(major_version, minor_version, revision_version):
		_network.exec(sender_id, &"alert", ["INVALID_VERSION"])
		return


func sign_up(email: String, password: String, major_version: int, minor_version: int, revision_version: int) -> void:
	var sender_id: int = _network.sender_id()

	if not _is_valid_version(major_version, minor_version, revision_version):
		_network.exec(sender_id, &"alert", ["INVALID_VERSION"])
		return


func _is_valid_version(major: int, minor: int, revision: int) -> bool:
	return (major == Constants.MAJOR_VERSION and minor == Constants.MINOR_VERSION and revision == Constants.REVISION_VERSION)
