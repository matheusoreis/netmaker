extends GridEntity2D
class_name Player

@export_category("Visuals")
@export var animated_sprite: AnimatedSprite2D
@export var camera_2d: Camera2D

@export_category("Mobile Controls")
@export var enable_swipe_controls: bool = true
@export var swipe_threshold: float = 40.0

var _is_local: bool = false

var _move_from: Vector2
var _move_to: Vector2
var _move_progress: float = 1.0

var _buffered_input: Vector2i = Vector2i.ZERO

var _touch_start: Vector2

const _WALK_ANIM: Dictionary = {
	Vector2i.LEFT:    "walk_left",
	Vector2i.RIGHT:   "walk_right",
	Vector2i.UP:      "walk_up",
	Vector2i.DOWN:    "walk_down",
	Vector2i(-1, -1): "walk_up",
	Vector2i( 1, -1): "walk_up",
	Vector2i(-1,  1): "walk_down",
	Vector2i( 1,  1): "walk_down",
}

const _IDLE_ANIM: Dictionary = {
	Vector2i.LEFT:    "idle_left",
	Vector2i.RIGHT:   "idle_right",
	Vector2i.UP:      "idle_up",
	Vector2i.DOWN:    "idle_down",
	Vector2i(-1, -1): "idle_up",
	Vector2i( 1, -1): "idle_up",
	Vector2i(-1,  1): "idle_down",
	Vector2i( 1,  1): "idle_down",
}


func _ready() -> void:
	super()
	move_started.connect(_on_move_started)
	move_finished.connect(_on_move_finished)
	move_blocked.connect(_on_move_blocked)
	direction_changed.connect(_on_direction_changed)

	if animated_sprite:
		animated_sprite.play("idle_down")


func setup_as_local() -> void:
	_is_local = true
	if camera_2d:
		camera_2d.enabled = true


func setup_as_remote() -> void:
	_is_local = false
	if camera_2d:
		camera_2d.enabled = false


func on_added_to_map() -> void:
	super()
	var world_pos := current_map.grid_to_world(map_position)
	position = world_pos
	_move_from = world_pos
	_move_to = world_pos
	_move_progress = 1.0


func _process(delta: float) -> void:
	super._process(delta)
	_update_visual(delta)

	if not _is_local:
		return

	_read_input()


func _input(event: InputEvent) -> void:
	if not enable_swipe_controls or not _is_local:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start = event.position
		else:
			_handle_swipe(event.position)


func _update_visual(delta: float) -> void:
	if _move_progress >= 1.0:
		return
	_move_progress = minf(_move_progress + delta / move_duration, 1.0)
	position = _move_from.lerp(_move_to, _move_progress)


func _read_input() -> void:
	_buffered_input = _get_input_direction()
	if is_idle() and _buffered_input != Vector2i.ZERO:
		enqueue_move(_buffered_input)


func _get_input_direction() -> Vector2i:
	var x: int = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var y: int = int(Input.is_action_pressed("ui_down"))  - int(Input.is_action_pressed("ui_up"))
	return Vector2i(x, y)


func _handle_swipe(touch_end: Vector2) -> void:
	var delta := touch_end - _touch_start
	if delta.length() < swipe_threshold:
		return

	var direction: Vector2i
	if abs(delta.x) > abs(delta.y):
		direction = Vector2i.RIGHT if delta.x > 0 else Vector2i.LEFT
	else:
		direction = Vector2i.DOWN if delta.y > 0 else Vector2i.UP

	if can_move and is_idle():
		enqueue_move(direction)


func _on_move_started(from: Vector2i, to: Vector2i) -> void:
	_move_from = position
	_move_to = current_map.grid_to_world(to)
	_move_progress = 0.0
	_play_anim(_WALK_ANIM, to - from)


func _on_move_finished(_grid_pos: Vector2i) -> void:
	if _buffered_input != Vector2i.ZERO:
		enqueue_move(_buffered_input)
	else:
		_play_anim(_IDLE_ANIM, facing)


func _on_move_blocked(_target: Vector2i, _reason: String) -> void:
	_play_anim(_IDLE_ANIM, facing)


func _on_direction_changed(new_direction: Vector2i) -> void:
	_play_anim(_IDLE_ANIM, new_direction)


func _play_anim(table: Dictionary, dir: Vector2i) -> void:
	if animated_sprite:
		animated_sprite.play(table.get(dir, "idle_down"))
