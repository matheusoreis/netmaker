extends Character
class_name Living


var is_walking: bool = false

var _pending_idle: bool = false


func _init(id: int, identifier: String, sprite_identifier: String, spritesheet_cols: int, spritesheet_rows: int, map_id: int, map_position: Vector2i, direction: Vector2i) -> void:
	super(id, identifier, sprite_identifier, spritesheet_cols, spritesheet_rows)

	self.map_id = map_id
	self.map_position = map_position
	self.direction = direction


func _ready() -> void:
	super()

	if _animator:
		_animator.animation_ended.connect(_on_animation_ended)


func _physics_process(delta: float) -> void:
	if is_walking:
		_advance_step(delta)

	super(delta)


func move_to(new_direction: Vector2i) -> void:
	if is_walking:
		return

	var target: Vector2i = map_position + new_direction

	if not _can_move_to(target):
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

	visual_offset = visual_offset.move_toward(Vector2.ZERO, step)
	if not visual_offset.is_zero_approx():
		return

	is_walking = false
	_play_idle()


func _execute_move(new_direction: Vector2i) -> void:
	map_position += new_direction

	visual_offset = Vector2(-new_direction * Constants.TILE_SIZE)

	direction = new_direction

	is_walking = true
	_play_walk()


func _can_move_to(_target: Vector2i) -> bool:
	return true


func _on_animation_ended(_anim_name: String) -> void:
	if _pending_idle and not is_walking:
		_pending_idle = false
		_animator.play(_animation_name("idle"))
