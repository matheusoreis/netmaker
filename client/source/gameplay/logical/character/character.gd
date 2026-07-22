extends Node2D
class_name Character


var id: int
var identifier: String

var spritesheet: String
var spritesheet_cols: int = 4
var spritesheet_rows: int = 4

var map_id: int
var map_position: Vector2i
var map_direction: Vector2i

var visual_anchor: Vector2i = Vector2i.ZERO
var visual_offset: Vector2 = Vector2.ZERO

var _animator: Animator
var _nameplate: CharacterNameplate

var _is_walking: bool = false
var _pending_idle: bool = false
var _move_queue: BoundedQueue = BoundedQueue.new(32)


func _init(id: int, identifier: String, spritesheet: String, spritesheet_cols: int, spritesheet_rows: int, map_id: int, map_position: Vector2i, map_direction: Vector2i) -> void:
	self.name = "Actor_%d" % id

	self.id = id
	self.identifier = identifier

	self.spritesheet = spritesheet
	self.spritesheet_cols = spritesheet_cols
	self.spritesheet_rows = spritesheet_rows

	self.map_id = map_id
	self.map_position = map_position
	self.map_direction = map_direction


func _ready() -> void:
	var texture: Texture2D = _load_entity_texture(spritesheet)
	if texture == null:
		return

	_animator = Animator.new(texture, spritesheet_cols, spritesheet_rows)
	_animator.name = "Animator"
	add_child(_animator)
	_animator.animation_ended.connect(_on_animation_ended)

	_nameplate = CharacterNameplate.new(identifier, overhead_anchor())
	_nameplate.name = "Nameplate"
	add_child(_nameplate)

	_register_animations()
	_play_idle()


func _physics_process(delta: float) -> void:
	var target: Vector2 = Vector2(map_position * Constants.TILE_SIZE) + visual_offset
	position = target.round()

	if _is_walking:
		_advance_step(delta)


func overhead_anchor() -> Vector2:
	var sprite_height: float = _calculate_sprite_height()
	return Vector2(Constants.TILE_SIZE / 2.0, visual_anchor.y - sprite_height)


func animator() -> Animator:
	return _animator


func nameplate() -> CharacterNameplate:
	return _nameplate


func move_to(direction: Vector2i) -> void:
	if not _move_queue.enqueue(direction):
		return

	if not _is_walking:
		_dequeue_next_move()


func _dequeue_next_move() -> void:
	if _move_queue.is_empty():
		return

	var direction: Vector2i = _move_queue.dequeue()
	_execute_move(direction)


func _execute_move(direction: Vector2i) -> void:
	var old_position: Vector2i = map_position
	var new_position: Vector2i = old_position + direction

	visual_offset = Vector2(-direction * Constants.TILE_SIZE)
	map_direction = direction
	map_position = new_position

	_sync_map_occupancy(old_position, new_position)

	_is_walking = true
	_play_walk()


func _advance_step(delta: float) -> void:
	var step: float = Constants.WALKING_SPEED * delta * Constants.TILE_SIZE

	visual_offset = visual_offset.move_toward(Vector2.ZERO, step)
	if not visual_offset.is_zero_approx():
		return

	_is_walking = false
	_on_step_completed()

	if not _move_queue.is_empty():
		_dequeue_next_move()
		return

	_play_idle()


func _sync_map_occupancy(_old_position: Vector2i, _new_position: Vector2i) -> void:
	pass


func _on_step_completed() -> void:
	pass


func _calculate_sprite_height() -> float:
	if not _animator:
		return 0.0

	var sprite: Sprite2D = _animator.read_sprite()
	if not sprite:
		return 0.0

	var texture: Texture2D = sprite.texture
	if not texture:
		return 0.0

	var frame_height: float = texture.get_height() / float(spritesheet_rows)
	return frame_height


func _register_animations() -> void:
	_animator.register("idle_down", 0, 0, 1.0, true)
	_animator.register("idle_left", 4, 4, 1.0, true)
	_animator.register("idle_right", 8, 8, 1.0, true)
	_animator.register("idle_up", 12, 12, 1.0, true)

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


func _on_animation_ended(_anim_name: String) -> void:
	if _pending_idle and not _is_walking:
		_pending_idle = false
		_animator.play(_animation_name("idle"))


func _animation_name(prefix: String) -> String:
	var row: String = ""
	match map_direction:
		Vector2i(0, -1):
			row = "up"
		Vector2i(0, 1):
			row = "down"
		Vector2i(-1, 0):
			row = "left"
		Vector2i(1, 0):
			row = "right"
		_:
			row = "down"

	return prefix + "_" + row


func _load_entity_texture(sprite: String) -> Texture2D:
	var path: String = "res://assets/gfx/actor/%s.png" % sprite.to_lower()

	if not ResourceLoader.exists(path):
		return null

	return load(path)
