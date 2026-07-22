extends Node2D
class_name CharacterAnimator

signal animation_started(anim_name: String)
signal animation_ended(anim_name: String)


class AnimationData:
	var first: int
	var last: int
	var fps: float
	var loop: bool

	func _init(first: int, last: int, fps: float = 6.0, loop: bool = true) -> void:
		self.first = first
		self.last = last
		self.fps = fps
		self.loop = loop


class AnimationState:
	var name: String = ""
	var playing: bool = false
	var should_finish: bool = false
	var first: int = 0
	var last: int = 0
	var fps: float = 6.0
	var loop: bool = true
	var current_frame: int = 0
	var accumulator: float = 0.0


var _animations: Dictionary = {}
var _state: AnimationState = AnimationState.new()
var _sprite: Sprite2D = null
var _cols: int = 4
var _rows: int = 8


func _init(texture: Texture2D, cols: int, rows: int) -> void:
	_cols = cols
	_rows = rows

	_sprite = Sprite2D.new()
	_sprite.name = "Sprite"
	_sprite.hframes = cols
	_sprite.vframes = rows
	_sprite.texture = texture
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.offset = _calculate_visual_anchor(texture, cols, rows)
	_sprite.centered = false

	add_child(_sprite)


func _physics_process(delta: float) -> void:
	if not _state.playing:
		return

	var frame_duration: float = 1.0 / _state.fps
	_state.accumulator += delta

	while _state.accumulator >= frame_duration:
		_state.accumulator -= frame_duration
		_advance_frame()


func register(anim_name: String, first: int, last: int, fps: float = 6.0, loop: bool = true) -> void:
	_animations[anim_name] = AnimationData.new(first, last, fps, loop)


func play(anim_name: String) -> void:
	if not _animations.has(anim_name):
		return

	var data: AnimationData = _animations[anim_name]
	var changed: bool = anim_name != _state.name

	_state.name = anim_name
	_state.first = data.first
	_state.last = data.last
	_state.fps = data.fps
	_state.loop = data.loop
	_state.should_finish = false
	_state.playing = true

	if changed or _state.current_frame < _state.first or _state.current_frame > _state.last:
		_state.current_frame = _state.first
		_state.accumulator = 0.0
		_apply_frame()
		animation_started.emit(anim_name)


func finish() -> void:
	if _state.playing:
		_state.should_finish = true


func stop() -> void:
	_state.playing = false
	_state.should_finish = false
	_state.accumulator = 0.0


func is_playing(anim_name: String = "") -> bool:
	if anim_name == "":
		return _state.playing
	return _state.playing and _state.name == anim_name


func has_animation(anim_name: String) -> bool:
	return _animations.has(anim_name)


func read_sprite() -> Sprite2D:
	return _sprite


func read_current_frame() -> int:
	return _state.current_frame


func read_current_name() -> String:
	return _state.name


func read_playing() -> bool:
	return _state.playing


func read_animations() -> Dictionary:
	return _animations


func read_animation_data(anim_name: String) -> AnimationData:
	if _animations.has(anim_name):
		return _animations[anim_name]
	return null


func _advance_frame() -> void:
	if _state.should_finish:
		_state.current_frame = _state.first
		_state.playing = false
		_state.should_finish = false
		_apply_frame()
		animation_ended.emit(_state.name)
		return

	var next_frame: int = _state.current_frame + 1

	if next_frame > _state.last:
		if not _state.loop:
			_state.current_frame = _state.last
			_state.playing = false
			_apply_frame()
			animation_ended.emit(_state.name)
			return
		next_frame = _state.first

	_state.current_frame = next_frame
	_apply_frame()


func _apply_frame() -> void:
	if _sprite:
		_sprite.frame = _state.current_frame


func _calculate_visual_anchor(texture: Texture2D, cols: int, rows: int) -> Vector2i:
	var frame_size: Vector2 = texture.get_size() / Vector2(cols, rows)
	var offset_x: int = floori((Constants.TILE_SIZE - frame_size.x) / 2.0)
	var offset_y: int = floori(Constants.TILE_SIZE - frame_size.y)
	return Vector2i(offset_x, offset_y)
