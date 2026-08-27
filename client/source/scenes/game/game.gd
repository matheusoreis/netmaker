extends Scene
class_name Game


var current_map: Map
var current_character: Character


func _ready() -> void:
	Network.exec(&"map_data")


func _physics_process(_delta: float) -> void:
	_handle_movement()


func _handle_movement() -> void:
	if current_map == null or current_character == null:
		return

	if current_character.is_transitioning():
		return

	if current_character.is_warping():
		return

	var direction: Vector2i = Vector2i.ZERO
	if Input.is_action_pressed("move_up"):
		direction = Vector2i.UP
	elif Input.is_action_pressed("move_down"):
		direction = Vector2i.DOWN
	elif Input.is_action_pressed("move_left"):
		direction = Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		direction = Vector2i.RIGHT

	if direction == Vector2i.ZERO:
		return

	if not current_map.can_pass(current_character.cell, direction):
		return

	current_character.move(direction)
	Network.exec(&"move_character", [direction])
