extends RefCounted
class_name Account


enum Role {
	NONE,
	MODERATOR,
	ADMINISTRATOR
}


var id: int

var email: String
var password: String

var role: Role

var access_at: int
var banned_at: int
var created_at: int
var updated_at: int


func _init(id: int, email: String, password: String, role: Role, access_at: int, banned_at: int, created_at: int, updated_at: int) -> void:
	self.id = id

	self.email = email
	self.password = password

	self.role = role

	self.access_at = access_at
	self.banned_at = banned_at
	self.created_at = created_at
	self.updated_at = updated_at
