extends GridEntity2D
class_name NpcClient

@export_category("Visuals")
@export var animated_sprite: AnimatedSprite2D

var _move_from: Vector2
var _move_to: Vector2
var _move_progress: float = 1.0
var _current_move_duration: float = 0.0

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


func _update_visual(delta: float) -> void:
	if _move_progress >= 1.0:
		return
	_move_progress = minf(_move_progress + delta / _current_move_duration, 1.0)
	position = _move_from.lerp(_move_to, _move_progress)


func _on_move_started(from: Vector2i, to: Vector2i) -> void:
	_move_from = position
	_move_to = current_map.grid_to_world(to)
	_move_progress = 0.0
	var direction: Vector2i = to - from
	_current_move_duration = move_duration * (1.414 if direction.x != 0 and direction.y != 0 else 1.0)
	_play_anim(_WALK_ANIM, direction)


func _on_move_finished(_grid_pos: Vector2i) -> void:
	_play_anim(_IDLE_ANIM, facing)


func _on_move_blocked(_target: Vector2i, _reason: String) -> void:
	_play_anim(_IDLE_ANIM, facing)


func _on_direction_changed(new_direction: Vector2i) -> void:
	_play_anim(_IDLE_ANIM, new_direction)


func _play_anim(table: Dictionary, dir: Vector2i) -> void:
	if animated_sprite:
		animated_sprite.play(table.get(dir, "idle_down"))
