extends GridEntity2D
class_name Player

@export var move_speed: float = 128.0
@export var sprite_2d: Sprite2D
@export var camera_2d: Camera2D

var _move_target: Vector2 = Vector2.ZERO
var _is_moving: bool = false
var _is_local: bool = false


func setup_as_local() -> void:
	_is_local = true
	if camera_2d:
		camera_2d.enabled = true


func setup_as_remote() -> void:
	_is_local = false
	if camera_2d:
		camera_2d.enabled = false


func on_added_to_map() -> void:
	super.on_added_to_map()
	_move_target = position


func move(direction: Vector2i) -> void:
	_attempt_move(direction)


func _process(delta: float) -> void:
	if _is_moving:
		_process_interpolation(delta)


func _advance_path() -> void:
	if _is_moving:
		return
	super._advance_path()


func _attempt_move(direction: Vector2i) -> void:
	if not current_map or not can_move or _is_moving:
		return

	if direction != facing:
		facing = direction
		direction_changed.emit(facing)

	var result: GridMap2D.MoveResult = current_map.request_move(self, direction)

	if not result.success:
		move_blocked.emit(result.to, result.rejection_reason)
		_queued_path.clear()
		return

	var from: Vector2i = result.from
	_move_target = result.world_target
	_is_moving = true

	current_map.confirm_move(self, from, map_position)
	move_started.emit(from, map_position)


func _process_interpolation(delta: float) -> void:
	if position.distance_to(_move_target) < 1.0:
		position = _move_target
		_is_moving = false
		move_finished.emit(map_position)
		_advance_path()
		return

	position = position.move_toward(_move_target, move_speed * delta)
