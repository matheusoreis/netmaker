extends Node


const JOYSTICK_DEAD_ZONE: float = 0.5


func _physics_process(_delta: float) -> void:
	_handle_movement()


func _handle_movement() -> void:
	var actor_id: int = GameSystem.actor_id
	if actor_id == null:
		return

	var actor: Actor = GameSystem.get_actor(actor_id)
	if actor == null or actor.is_walking:
		return

	var input: Vector2 = Input.get_vector(
		"walking_left",
		"walking_right",
		"walking_up",
		"walking_down"
	)

	var direction: Vector2i = Vector2i.ZERO

	if input.length() >= JOYSTICK_DEAD_ZONE:
		if abs(input.x) > abs(input.y):
			direction = Vector2i.RIGHT if input.x > 0 else Vector2i.LEFT
		else:
			direction = Vector2i.DOWN if input.y > 0 else Vector2i.UP

	actor.move(direction)
