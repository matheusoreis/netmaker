extends Entity
class_name Character


var account: int


func _init(id: int, identifier: String, spritesheet: String, map: int, cell: Vector2i, facing: Vector2i, account: int) -> void:
	super(id, identifier, spritesheet, map, cell, facing)

	self.account = account


func move(direction: Vector2i) -> void:
	facing = direction
	cell += direction
