extends Living
class_name Actor


var _camera: ActorCamera


func _ready() -> void:
	super()

	if _is_local_actor():
		_camera = ActorCamera.new(read_overhead_anchor())
		_camera.name = "Camera"
		add_child(_camera)


func _is_local_actor() -> bool:
	return true if GameActors.actor_id == self.id else false
