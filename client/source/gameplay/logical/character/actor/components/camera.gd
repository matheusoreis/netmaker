extends Camera2D
class_name ActorCamera


func _ready() -> void:
	zoom = Vector2(2, 2)


func set_map_limits(map: Map) -> void:
	var pixel_size: Vector2i = map.pixel_size()

	limit_left = 0
	limit_top = 0
	limit_right = pixel_size.x
	limit_bottom = pixel_size.y
