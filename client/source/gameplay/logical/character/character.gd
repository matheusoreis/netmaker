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

var _animator: CharacterAnimator
var _nameplate: CharacterNameplate


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

	_animator = CharacterAnimator.new(texture, spritesheet_cols, spritesheet_rows)
	_animator.name = "Animator"
	add_child(_animator)

	_nameplate = CharacterNameplate.new(identifier, overhead_anchor())
	_nameplate.name = "Nameplate"
	add_child(_nameplate)

	_register_animations()
	_play_idle()


func _physics_process(_delta: float) -> void:
	var target: Vector2 = Vector2(map_position * Constants.TILE_SIZE) + visual_offset
	position = target.round()


func overhead_anchor() -> Vector2:
	var sprite_height: float = _calculate_sprite_height()
	return Vector2(Constants.TILE_SIZE / 2.0, visual_anchor.y - sprite_height)


func animator() -> CharacterAnimator:
	return _animator


func nameplate() -> CharacterNameplate:
	return _nameplate


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

	var animation: String = _animation_name("idle")
	_animator.play(animation)


func _play_walk() -> void:
	if not _animator:
		return

	_animator.play(_animation_name("walk"))


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
