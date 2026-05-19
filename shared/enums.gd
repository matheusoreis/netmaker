extends RefCounted
class_name Enums


enum AuthError {
	# Sucesso
	SIGN_IN_OK,
	SIGN_UP_OK,

	# Erros de versão e formato
	INVALID_VERSION,
	INVALID_USERNAME,
	INVALID_PASSWORD,
	PASSWORD_MISMATCH,

	# Erros de conta
	ACCOUNT_NOT_FOUND,
	ACCOUNT_ALREADY_EXISTS,
	WRONG_PASSWORD,

	# Erros internos
	DATABASE_ERROR,
}
