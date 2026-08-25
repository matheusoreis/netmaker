extends RefCounted
class_name Models


func from_row(row: Array, cols: PackedStringArray) -> void:
	for i in cols.size():
		set(cols[i], row[i])


func to_array() -> Array:
	return []


class AccountModel extends Models:
	var id: int
	var email: String
	var password: String
	var role: int
	var access_at: int
	var banned_at: int
	var created_at: int
	var updated_at: int


	func to_array() -> Array:
		return [
			id,
			email,
			password,
			role,
			access_at,
			banned_at,
			created_at,
			updated_at
		]


class CharacterModel extends Models:
	var id: int
	var identifier: String
	var account: int
	var spritesheet: String
	var map: int
	var cell_x: int
	var cell_y: int
	var facing_x: int
	var facing_y: int
	var access_at: int
	var created_at: int
	var updated_at: int


	func to_array() -> Array:
		return [
			self.id,
			self.identifier,
			self.account,
			self.spritesheet,
			self.map,
			self.cell_x,
			self.cell_y,
			self.facing_x,
			self.facing_y,
			self.access_at,
			self.created_at,
			self.updated_at
		]
