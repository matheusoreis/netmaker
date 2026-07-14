extends Node2D
class_name CharacterAnimator


signal animation_started(anim_name: String)
signal animation_ended(anim_name: String)


var _animations: Dictionary = {}
var _current_name: String = ""
var _anim_first: int = 0
var _anim_last: int = 0
var _anim_fps: float = 6.0
var _anim_loop: bool = true
var _current_frame: int = 0
var _accumulator: float = 0.0
var _playing: bool = false
var _should_finish: bool = false
var _eager: bool = true

var _sprite: Sprite2D = null
var _cols: int = 4
var _rows: int = 8


func _init(texture: Texture2D, cols: int, rows: int) -> void:
	_cols = cols
	_rows = rows

	if _sprite:
		_sprite.queue_free()

	_sprite = Sprite2D.new()
	_sprite.name = "Sprite"
	_sprite.hframes = cols
	_sprite.vframes = rows

	texture.set_meta("filter", CanvasItem.TEXTURE_FILTER_NEAREST)
	_sprite.texture = texture
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	_sprite.offset = _calculate_visual_anchor(texture, cols, rows)
	_sprite.centered = false

	add_child(_sprite)


func _physics_process(delta: float) -> void:
	if not _playing:
		return

	var frame_duration: float = 1.0 / _anim_fps
	_accumulator += delta

	while _accumulator >= frame_duration:
		_accumulator -= frame_duration
		_advance_frame(frame_duration)


func register(anim_name: String, first: int, last: int, fps: float = 6.0, loop: bool = true) -> void:
	_animations[anim_name] = {
		"first": first,
		"last": last,
		"fps": fps,
		"loop": loop,
	}


func play(anim_name: String) -> void:
	if not _animations.has(anim_name):
		return

	var data: Dictionary = _animations[anim_name]
	var changed: bool = anim_name != _current_name

	_anim_first = data["first"]
	_anim_last = data["last"]
	_anim_fps = data["fps"]
	_anim_loop = data["loop"]
	_should_finish = false

	var should_reset: bool = changed or not _playing
	_current_name = anim_name
	_playing = true

	if not should_reset:
		return

	_current_frame = _anim_first
	_accumulator = (1.0 / _anim_fps) * 0.5 if _eager else 0.0
	_apply_frame()
	animation_started.emit(anim_name)


func finish() -> void:
	if _playing:
		_should_finish = true


func stop() -> void:
	_playing = false
	_should_finish = false
	_accumulator = 0.0


func is_playing(anim_name: String = "") -> bool:
	if anim_name == "":
		return _playing
	return _playing and _current_name == anim_name


func has_animation(anim_name: String) -> bool:
	return _animations.has(anim_name)


func _advance_frame(frame_duration: float) -> void:
	if _should_finish:
		_current_frame = _anim_first
		_accumulator = frame_duration * 0.5 if _eager else 0.0
		_playing = false
		_should_finish = false
		_apply_frame()
		animation_ended.emit(_current_name)
		return

	var next_frame: int = _current_frame + 1

	if next_frame > _anim_last:
		if not _anim_loop:
			_current_frame = _anim_last
			_playing = false
			_apply_frame()
			animation_ended.emit(_current_name)
			return
		next_frame = _anim_first

	_current_frame = next_frame
	_apply_frame()


func _apply_frame() -> void:
	if _sprite:
		_sprite.frame = _current_frame


func _calculate_visual_anchor(texture: Texture2D, cols: int, rows: int) -> Vector2i:
	var frame_size: Vector2 = texture.get_size() / Vector2(cols, rows)
	var offset_x: int = floori((Constants.TILE_SIZE - frame_size.x) / 2.0)
	var offset_y: int = floori(Constants.TILE_SIZE - frame_size.y)

	return Vector2i(offset_x, offset_y)
