extends Character
class_name Actor


var access: int


func _init(id: int, identifier: String, spritesheet: String, spritesheet_cols: int, spritesheet_rows: int, map_id: int, map_position: Vector2i, map_direction: Vector2i, access: int) -> void:
	super(id, identifier, spritesheet, spritesheet_cols, spritesheet_rows, map_id, map_position, map_direction)

	self.access = access
