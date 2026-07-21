extends Node

const JOYSTICK_DEAD_ZONE: float = 0.5


func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_no_pixel()
	_handle_map_collisions()


func _handle_movement() -> void:
	var actor: Actor = GameActors.local_actor()
	if actor == null:
		return

	var map: Map = GameMaps.current_map()
	if map == null:
		return

	var input: Vector2 = Input.get_vector(
		"walking_left",
		"walking_right",
		"walking_up",
		"walking_down"
	)

	if input.length() < JOYSTICK_DEAD_ZONE:
		return

	var direction: Vector2i = Vector2i.ZERO

	if abs(input.x) > abs(input.y):
		direction = Vector2i.RIGHT if input.x > 0 else Vector2i.LEFT
	else:
		direction = Vector2i.DOWN if input.y > 0 else Vector2i.UP

	actor.move_to(direction)


func _handle_no_pixel() -> void:
	if Input.is_action_just_pressed("nopixel"):
		GameNopixel.toggle_enabled()


func _handle_map_collisions() -> void:
	if Input.is_action_just_pressed("map_collisions"):
		var map: Map = GameMaps.current_map()
		if map == null:
			return

		Sender.update_map(map)
