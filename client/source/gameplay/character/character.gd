extends Node2D
class_name Character


var id: int
var identifier: String

var sprite_identifier: String
var spritesheet_cols: int = 4
var spritesheet_rows: int = 4

var map_id: int
var map_position: Vector2i

var _visual_anchor: Vector2i = Vector2i.ZERO
var visual_offset: Vector2 = Vector2.ZERO

var direction: Vector2i

var _animator: CharacterAnimator
var _nameplate: CharacterNameplate


func _init(id: int, identifier: String, sprite_identifier: String, spritesheet_cols: int, spritesheet_rows: int) -> void:
	self.name = "Actor%d" % id

	self.id = id
	self.identifier = identifier

	self.sprite_identifier = sprite_identifier
	self.spritesheet_cols = spritesheet_cols
	self.spritesheet_rows = spritesheet_rows


func _ready() -> void:
	var texture: Texture2D = _get_entity_texture(sprite_identifier)
	if texture == null:
		return

	_animator = CharacterAnimator.new(texture, spritesheet_cols, spritesheet_rows)
	_animator.name = "Animator"
	add_child(_animator)

	_nameplate = CharacterNameplate.new(identifier, get_overhead_anchor())
	_nameplate.name = "Nameplate"
	add_child(_nameplate)

	_register_animations()


func _physics_process(_delta: float) -> void:
	var target: Vector2 = Vector2(map_position * Constants.TILE_SIZE) + visual_offset
	position = target.round()


func get_overhead_anchor() -> Vector2:
	return Vector2(Constants.TILE_SIZE / 2.0, _visual_anchor.y)


func _register_animations() -> void:
	_animator.register("idle_down", 0, 0, 1.0, true)
	_animator.register("idle_left", 4, 4, 1.0, true)
	_animator.register("idle_right", 8, 8, 1.0, true)
	_animator.register("idle_up", 12, 12, 1.0, true)


func _play_idle() -> void:
	if not _animator:
		return

	var animation: String = _animation_name("idle")
	_animator.play(animation)


func _animation_name(prefix: String) -> String:
	var row: String = ""
	match direction:
		Vector2i.DOWN:
			row = "down"
		Vector2i.LEFT:
			row = "left"
		Vector2i.RIGHT:
			row = "right"
		Vector2i.UP:
			row = "up"

	return prefix + "_" + row


func _get_entity_texture(sprite: String) -> Texture2D:
	var path: String = "res://assets/gfx/actor/%s.png" % sprite.to_lower()

	if not ResourceLoader.exists(path):
		return null

	return load(path)
