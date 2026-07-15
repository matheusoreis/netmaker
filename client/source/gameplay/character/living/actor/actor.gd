extends Living
class_name Actor


var _camera: ActorCamera
var _is_local: bool = false


func _ready() -> void:
	super()

	if _is_local:
		_camera = ActorCamera.new()
		_camera.name = "Camera"
		add_child(_camera)


func set_local(is_local: bool) -> void:
	_is_local = is_local


func setup_camera(map: Map) -> void:
	if _is_local and _camera:
		_camera.set_map_limits(map)
