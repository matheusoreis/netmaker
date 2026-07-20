extends Node
class_name Character


var id: int

var identifier: String

var spritesheet: String
var spritesheet_cols: int = 4
var spritesheet_rows: int = 4

var map_id: int
var map_position: Vector2i
var map_direction: Vector2i


func _init(id: int, identifier: String, spritesheet: String, spritesheet_cols: int, spritesheet_rows: int, map_id: int, map_position: Vector2i, map_direction: Vector2i) -> void:
	self.id = id

	self.identifier = identifier

	self.spritesheet = spritesheet
	self.spritesheet_cols = spritesheet_cols
	self.spritesheet_rows = spritesheet_rows

	self.map_id = map_id
	self.map_position = map_position
	self.map_direction = map_direction
