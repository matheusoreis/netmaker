extends Character
class_name Actor


var access: int
var is_local: bool = false

var _camera: ActorCamera
var _is_walking: bool = false
var _pending_idle: bool = false


func _init(id: int, identifier: String, spritesheet: String, spritesheet_cols: int, spritesheet_rows: int, map_id: int, map_position: Vector2i, map_direction: Vector2i, access: int) -> void:
	super(id, identifier, spritesheet, spritesheet_cols, spritesheet_rows, map_id, map_position, map_direction)
	self.access = access


func _ready() -> void:
	super()

	if _animator:
		_animator.animation_ended.connect(_on_animation_ended)

	if is_local:
		_ensure_camera()


func _physics_process(delta: float) -> void:
	if _is_walking:
		_advance_step(delta)

	super(delta)


func setup_camera(map: Map) -> void:
	if not is_local:
		return

	_ensure_camera()
	_camera.set_map_limits(map)


func move_to(direction: Vector2i) -> void:
	if not is_local:
		_execute_move(direction)
		return

	if _is_walking:
		return

	var map: Map = GameMaps.current_map()
	if not map:
		return

	var target: Vector2i = map_position + direction
	if not _can_move_to(map, target):
		return

	_execute_move(direction)
	Sender.move(direction)


func _register_animations() -> void:
	super()

	_animator.register("walk_down", 0, 3, 6, true)
	_animator.register("walk_left", 4, 7, 6, true)
	_animator.register("walk_right", 8, 11, 6, true)
	_animator.register("walk_up", 12, 15, 6, true)


func _play_idle() -> void:
	if not _animator:
		return

	var anim_name: String = _animation_name("idle")

	if _animator.is_playing():
		_pending_idle = true
		_animator.finish()
	else:
		_animator.play(anim_name)


func _play_walk() -> void:
	if not _animator:
		return

	_pending_idle = false
	_animator.play(_animation_name("walk"))


func _execute_move(direction: Vector2i) -> void:
	var old_position: Vector2i = map_position
	var new_position: Vector2i = old_position + direction

	visual_offset = Vector2(-direction * Constants.TILE_SIZE)
	map_direction = direction
	map_position = new_position

	var map: Map = GameMaps.current_map()
	if map:
		map.vacate(old_position)
		map.occupy(new_position, id)

	_is_walking = true
	_play_walk()


func _advance_step(delta: float) -> void:
	var step: float = Constants.WALKING_SPEED * delta * Constants.TILE_SIZE

	visual_offset = visual_offset.move_toward(Vector2.ZERO, step)
	if not visual_offset.is_zero_approx():
		return

	_is_walking = false
	_play_idle()
	_on_step_completed()


func _can_move_to(map: Map, target: Vector2i) -> bool:
	if not map.is_within_bounds(target):
		return false

	if map.is_solid(target):
		return false

	var direction: Vector2i = target - map_position
	if not map.can_pass(map_position, direction):
		return false

	return true


func _on_step_completed() -> void:
	pass


func _on_animation_ended(_anim_name: String) -> void:
	if _pending_idle and not _is_walking:
		_pending_idle = false
		_animator.play(_animation_name("idle"))


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
