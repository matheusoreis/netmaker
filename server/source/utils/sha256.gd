extends RefCounted
class_name Sha256


const SEPARATOR: String = ":"
const SALT_LENGTH: int = 32
const ITERATIONS: int = 10_000


static func hash_password(password: String) -> String:
	var crypto := Crypto.new()
	var salt_bytes: PackedByteArray = crypto.generate_random_bytes(SALT_LENGTH)
	var salt_hex: String = salt_bytes.hex_encode()
	var hash_hex: String = _stretch(salt_hex, password)
	return salt_hex + SEPARATOR + hash_hex


static func verify_password(password: String, stored_value: String) -> bool:
	if SEPARATOR not in stored_value:
		return false

	var parts: PackedStringArray = stored_value.split(SEPARATOR)
	if parts.size() != 2:
		return false

	var salt_hex: String = parts[0]
	var original_hash: String = parts[1]

	if salt_hex.length() != SALT_LENGTH * 2:
		return false

	var current_hash: String = _stretch(salt_hex, password)
	return _constant_time_equals(current_hash, original_hash)


static func _stretch(salt_hex: String, password: String) -> String:
	var result: String = (salt_hex + password).sha256_text()
	for i in range(ITERATIONS - 1):
		result = (salt_hex + result).sha256_text()
	return result


static func _constant_time_equals(a: String, b: String) -> bool:
	if a.length() != b.length():
		return false

	var result: int = 0
	for i in range(a.length()):
		result |= a.unicode_at(i) ^ b.unicode_at(i)

	return result == 0
