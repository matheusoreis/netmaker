extends RefCounted
class_name Sha256


const SEPARATOR: String = ":"
const SALT_LENGTH: int = 32


func make(password: String) -> String:
	var crypto = Crypto.new()

	var salt_bytes = crypto.generate_random_bytes(SALT_LENGTH)
	var salt_hex = salt_bytes.hex_encode()
	var hash_hex = (password + salt_hex).sha256_text()

	return salt_hex + SEPARATOR + hash_hex


func verify(password: String, stored: String) -> bool:
	var parts = stored.split(SEPARATOR)
	if parts.size() != 2:
		return false

	var salt_hex = parts[0]
	var hash_hex = parts[1]

	return (password + salt_hex).sha256_text() == hash_hex
