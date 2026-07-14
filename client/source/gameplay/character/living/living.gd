extends Character
class_name Living


var is_walking: bool = false

var _pending_idle: bool = false


func _init(id: int, identifier: String, sprite_identifier: String, spritesheet_cols: int, spritesheet_rows: int, map_position: Vector2i, direction: Vector2i) -> void:
	super(id, identifier, sprite_identifier, spritesheet_cols, spritesheet_rows)

	self._map_position = map_position
	self._direction = direction


func _ready() -> void:
	super()

	if _animator:
		_animator.animation_ended.connect(_on_animation_ended)


func _physics_process(delta: float) -> void:
	if is_walking:
		_advance_step(delta)

	super(delta)


func set_direction(new_direction: Vector2i) -> void:
	if _direction == new_direction:
		return

	_direction = new_direction

	if not is_walking and _animator:
		_animator.play(_animation_name("idle"))


func move_to(map: Map, new_direction: Vector2i) -> void:
	if is_walking:
		return



	var target: Vector2i = _map_position + new_direction
	if not _can_move_to(map, target):
		return

	_execute_move(new_direction)


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


func _advance_step(delta: float) -> void:
	var step: float = Constants.WALKING_SPEED * delta * Constants.TILE_SIZE

	_visual_offset = _visual_offset.move_toward(Vector2.ZERO, step)
	if not _visual_offset.is_zero_approx():
		return

	is_walking = false
	_play_idle()


func _execute_move(new_direction: Vector2i) -> void:
	_map_position += new_direction

	_visual_offset = Vector2(-new_direction * Constants.TILE_SIZE)
	_direction = new_direction

	is_walking = true
	_play_walk()


func _can_move_to(map: Map, target: Vector2i) -> bool:
	if not map.is_within_bounds(target):
		return false

	if map.is_solid(target):
		return false

	var direction: Vector2i = target - _map_position
	if not map.can_pass(_map_position, direction):
		return false

	return true


func _on_animation_ended(_anim_name: String) -> void:
	if _pending_idle and not is_walking:
		_pending_idle = false
		_animator.play(_animation_name("idle"))
