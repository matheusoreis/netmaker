extends RefCounted
class_name Entity


var id: int
var identifier: String

var spritesheet: String

var map: int
var cell: Vector2i
var facing: Vector2i


func _init() -> void:
	self.id = id
	self.identifier = identifier

	self.spritesheet = spritesheet

	self.map = map
	self.cell = cell
	self.facing = facing
