extends Camera2D
class_name ActorCamera


func _init(overhead_anchor: Vector2i) -> void:
	position = overhead_anchor


func _ready() -> void:
	zoom = Vector2i(2, 2)
