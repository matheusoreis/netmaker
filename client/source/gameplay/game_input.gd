extends Node


func _physics_process(_delta: float) -> void:
	_handle_movement()


func _handle_movement() -> void:
	var actor_id: int = GameSystem.actor_id
	if actor_id == null:
		return

	var actor: Actor = GameSystem.get_actor(actor_id)
	if actor == null or actor.is_walking:
		return

	var direction: Vector2i = Vector2i.ZERO

	if Input.is_action_pressed("move_down"):
		direction = Vector2i.DOWN
	elif Input.is_action_pressed("move_up"):
		direction = Vector2i.UP
	elif Input.is_action_pressed("move_left"):
		direction = Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		direction = Vector2i.RIGHT

	actor.move(direction)
