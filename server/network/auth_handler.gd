extends Node
class_name AuthHandler


var _sha256: Sha256 = Sha256.new()


func _ready() -> void:
	Network.register(&"AuthHandler", [request_sign_in, request_sign_up])


func request_sign_in(username: String, password: String, major: int, minor: int, revision: int) -> Enums.AuthError:
	if not _is_version_valid(major, minor, revision):
		return Enums.AuthError.INVALID_VERSION

	if not _is_username_valid(username):
		return Enums.AuthError.INVALID_USERNAME

	if not _is_password_valid(password):
		return Enums.AuthError.INVALID_PASSWORD

	var account: AccountModel = await Database.row(
		"SELECT id, username, password_hash, is_banned FROM accounts WHERE username = ?1 LIMIT 1;",
		[username],
		AccountModel
	) as AccountModel

	if not account:
		return Enums.AuthError.ACCOUNT_NOT_FOUND

	if not _sha256.verify_password(password, account.password_hash):
		return Enums.AuthError.WRONG_PASSWORD

	return Enums.AuthError.SIGN_IN_OK


func request_sign_up(username: String, password: String, re_password: String, major: int, minor: int, revision: int) -> Enums.AuthError:
	if not _is_version_valid(major, minor, revision):
		return Enums.AuthError.INVALID_VERSION

	if not _is_username_valid(username):
		return Enums.AuthError.INVALID_USERNAME

	if not _is_password_valid(password):
		return Enums.AuthError.INVALID_PASSWORD

	if password != re_password:
		return Enums.AuthError.PASSWORD_MISMATCH

	var existing: AccountModel = await Database.row(
		"SELECT id FROM accounts WHERE username = ?1 LIMIT 1;",
		[username],
		AccountModel
	) as AccountModel

	if existing:
		return Enums.AuthError.ACCOUNT_ALREADY_EXISTS

	var hashed: String = _sha256.hash_password(password)

	var err: Error = await Database.exec(
		"INSERT INTO accounts (username, password_hash, created_at) VALUES (?1, ?2, ?3);",
		[username, hashed, Database.now()]
	)

	if err != OK:
		return Enums.AuthError.DATABASE_ERROR

	return Enums.AuthError.SIGN_UP_OK


func _is_version_valid(major: int, minor: int, revision: int) -> bool:
	return major == Constants.Server.VERSION_MAJOR \
		and minor == Constants.Server.VERSION_MINOR \
		and revision == Constants.Server.VERSION_REVISION


func _is_username_valid(username: String) -> bool:
	var length: int = username.length()
	if length < Constants.Server.MIN_USERNAME_LENGTH or length > Constants.Server.MAX_USERNAME_LENGTH:
		return false

	var regex: RegEx = RegEx.new()
	regex.compile(Constants.Server.USERNAME_REGEX)
	return regex.search(username) != null


func _is_password_valid(password: String) -> bool:
	return password.length() >= Constants.Server.MIN_PASSWORD_LENGTH and password.length() <= Constants.Server.MAX_PASSWORD_LENGTH
