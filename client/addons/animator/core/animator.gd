extends Node2D
class_name Animator


signal animation_started(anim_name: String)
signal animation_ended(anim_name: String)


var _animations: Dictionary[String, AnimatorData] = {}

var _state: AnimatorState = AnimatorState.new()
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

	var data: AnimatorData = _animations[_state.name]
	var frame_duration := data.frame_duration()

	if _state.tick(delta, frame_duration):
		_state.consume_frame()
		_advance_frame(data)


func register(anim_name: String, first: int, last: int, fps: float = 6.0, loop: bool = true) -> void:
	_animations[anim_name] = AnimatorData.new(first, last, fps, loop)


func play(anim_name: String) -> void:
	if not _animations.has(anim_name):
		return

	var data: AnimatorData = _animations[anim_name]
	var changed: bool = anim_name != _state.name

	_state.setup(data, anim_name)

	if changed or _state.needs_reset():
		_state.reset()
		_apply_frame()
		animation_started.emit(anim_name)


func finish() -> void:
	if _state.playing:
		_state.should_finish = true


func stop() -> void:
	_state.stop()


func is_playing(anim_name: String = "") -> bool:
	return _state.is_playing(anim_name)


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


func read_animation_data(anim_name: String) -> AnimatorData:
	return _animations.get(anim_name)


func _advance_frame(data: AnimatorData) -> void:
	if _state.should_finish:
		_state.finish_now()
		_apply_frame()
		animation_ended.emit(_state.name)
		return

	if data.is_last_frame(_state.current_frame) and not _state.loop:
		_state.playing = false
		_apply_frame()
		animation_ended.emit(_state.name)
		return

	_state.current_frame = data.next_frame(_state.current_frame)
	_apply_frame()


func _apply_frame() -> void:
	if _sprite:
		_sprite.frame = _state.current_frame


func _calculate_visual_anchor(texture: Texture2D, cols: int, rows: int) -> Vector2i:
	var frame_size: Vector2 = texture.get_size() / Vector2(cols, rows)
	var offset_x: int = floori((Constants.TILE_SIZE - frame_size.x) / 2.0)
	var offset_y: int = floori(Constants.TILE_SIZE - frame_size.y)
	return Vector2i(offset_x, offset_y)
