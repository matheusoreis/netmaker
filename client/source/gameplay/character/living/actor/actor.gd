extends Living
class_name Actor


var _camera: ActorCamera

var _is_local: bool = false


func read_is_local() -> bool:
	return _is_local


func write_is_local(value: bool) -> void:
	_is_local = value

	if _is_local:
		_ensure_camera()
	else:
		_remove_camera()


func setup_camera(map: Map) -> void:
	if not _is_local:
		return

	_ensure_camera()
	_camera.set_map_limits(map)


func move_to(map: Map, new_direction: Vector2i) -> void:
	if not _is_local:
		_execute_move(new_direction)
		return

	if is_walking:
		return

	var target: Vector2i = read_map_position() + new_direction
	if not _can_move_to(map, target):
		return

	_execute_move(new_direction)
	Network.exec(&"move", [new_direction])


func _on_step_completed() -> void:
	pass


func _ensure_camera() -> void:
	if _camera:
		return

	_camera = ActorCamera.new()
	_camera.name = "Camera"
	add_child(_camera)


func _remove_camera() -> void:
	if not _camera:
		return

	_camera.queue_free()
	_camera = null
