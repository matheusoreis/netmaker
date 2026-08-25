extends Entity
class_name Character


func move(direction: Vector2i) -> void:
	facing = direction
	cell += direction
