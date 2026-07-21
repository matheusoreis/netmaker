extends Character
class_name Actor


var access: Enums.ActorAccess

var is_local: bool = false

var _camera: ActorCamera
var _is_walking: bool = false
var _pending_idle: bool = false

var _move_queue: BoundedQueue = BoundedQueue.new(16)


func _init(id: int, identifier: String, spritesheet: String, spritesheet_cols: int, spritesheet_rows: int, map_id: int, map_position: Vector2i, map_direction: Vector2i, access: Enums.ActorAccess) -> void:
	super(id, identifier, spritesheet, spritesheet_cols, spritesheet_rows, map_id, map_position, map_direction)

	self.access = access


func _ready() -> void:
	super()

	if _animator:
		_animator.animation_ended.connect(_on_animation_ended)

	if is_local:
		_ensure_camera()


func _physics_process(delta: float) -> void:
	super(delta)

	if _is_walking:
		_advance_step(delta)


func setup_camera(map: Map) -> void:
	if not is_local:
		return

	_ensure_camera()
	_camera.set_map_limits(map)


func move_to(direction: Vector2i) -> void:
	if not is_local:
		_queue_remote_move(direction)
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


func _queue_remote_move(direction: Vector2i) -> void:
	if not _move_queue.enqueue(direction):
		return

	if not _is_walking:
		_dequeue_next_move()


func _dequeue_next_move() -> void:
	if _move_queue.is_empty():
		return

	var direction: Vector2i = _move_queue.dequeue()
	_execute_move(direction)


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
		map.remove_actor(old_position, id)
		map.place_actor(new_position, id)

	_is_walking = true
	_play_walk()


func _advance_step(delta: float) -> void:
	var step: float = Constants.WALKING_SPEED * delta * Constants.TILE_SIZE

	visual_offset = visual_offset.move_toward(Vector2.ZERO, step)
	if not visual_offset.is_zero_approx():
		return

	_is_walking = false
	_on_step_completed()

	if not is_local and not _move_queue.is_empty():
		_dequeue_next_move()
		return

	_play_idle()


func _can_move_to(map: Map, target: Vector2i) -> bool:
	var direction: Vector2i = target - map_position
	return map.can_pass(map_position, direction)


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
