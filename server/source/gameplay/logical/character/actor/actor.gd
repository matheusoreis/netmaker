extends Character
class_name Actor


var access: Enums.ActorAccess


func _init(
	id: int,
	identifier: String,
	spritesheet: String,
	spritesheet_cols: int,
	spritesheet_rows: int,
	map_id: int,
	map_position: Vector2i,
	map_direction: Vector2i,
	access: Enums.ActorAccess
) -> void:
	super(
		id,
		identifier,
		spritesheet,
		spritesheet_cols,
		spritesheet_rows,
		map_id,
		map_position,
		map_direction
	)

	self.access = access


func is_moderator() -> bool:
	return self.access == Enums.ActorAccess.MODERATOR


func is_administrator() -> bool:
	return self.access == Enums.ActorAccess.ADMINISTRATOR
