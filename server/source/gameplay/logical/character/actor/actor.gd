extends Character
class_name Actor


var access: int


func _init(id: int, identifier: String, spritesheet: String, spritesheet_cols: int, spritesheet_rows: int, map_position: Vector2i, map_direction: Vector2i, access: int) -> void:
	super(id, identifier, spritesheet, spritesheet_cols, spritesheet_rows, map_position, map_direction)

	self.access = access


func can_move_to(map: Map, target: Vector2i) -> bool:
	if not map.is_within_bounds(target):
		return false

	if map.is_solid(target):
		return false

	var direction: Vector2i = target - self.map_position
	if not map.can_pass(self.map_position, direction):
		return false

	return true
