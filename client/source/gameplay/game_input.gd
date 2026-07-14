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

	if Input.is_action_pressed("walking_up"):
		direction = Vector2i.UP
	if Input.is_action_pressed("walking_down"):
		direction = Vector2i.DOWN
	if Input.is_action_pressed("walking_left"):
		direction = Vector2i.LEFT
	if Input.is_action_pressed("walking_right"):
		direction = Vector2i.RIGHT

	if direction == Vector2i.ZERO:
		var joy_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var joy_y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		var joy_vec = Vector2(joy_x, joy_y)

		if joy_vec.length() >= 0.2:
			match rad_to_deg(joy_vec.angle()):
				45:
					direction = Vector2i.DOWN
				135:
					direction = Vector2i.LEFT
				-135:
					direction = Vector2i.UP
				_:
					direction = Vector2i.RIGHT

	actor.move(direction)
