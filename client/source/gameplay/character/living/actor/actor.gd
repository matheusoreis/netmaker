extends Living
class_name Actor


var _camera: ActorCamera


func _ready() -> void:
	super()

	if _is_local_actor():
		_camera = ActorCamera.new()
		_camera.name = "Camera"
		add_child(_camera)


func move(direction: Vector2i) -> void:
	_execute_move(direction)


func _is_local_actor() -> bool:
	return true if GameSystem.actor_id == self.id else false
