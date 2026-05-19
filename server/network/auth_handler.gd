extends Node
class_name AuthHandler


func _ready() -> void:
	Network.register(&"AuthHandler", [])


func _is_version_valid(major: int, minor: int, revision: int) -> bool:
	return major == Constants.Server.VERSION_MAJOR \
		and minor == Constants.Server.VERSION_MINOR \
		and revision == Constants.Server.VERSION_REVISION


func _is_username_valid(username: String) -> bool:
	if username.length() < Constants.Server.MIN_PASSWORD_LENGTH or username.length() > Constants.Server.MAX_USERNAME_LENGTH:
		return false

	var regex: RegEx = RegEx.new()
	regex.compile(Constants.Server.USERNAME_REGEX)
	return regex.search(username) != null


func _is_password_valid(password: String) -> bool:
	return password.length() >= Constants.Server.MIN_PASSWORD_LENGTH and password.length() <= Constants.Server.MAX_PASSWORD_LENGTH
