extends Control
class_name CharacterNameplate


const PADDING_X: float = 10.0
const PADDING_Y: float = 2.0

const FONT_SIZE: int = 12

const OFFSET_Y: float = -18.0

const BG_COLOR: Color = Color(0.15, 0.15, 0.15, 0.7)
const TEXT_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)


var text: String

var _overhead_anchor: Vector2
var _style_box: StyleBoxFlat


func _init(text: String, overhead_anchor: Vector2) -> void:
	self.text = text

	_overhead_anchor = overhead_anchor


func _ready() -> void:
	_style_box = StyleBoxFlat.new()
	_style_box.bg_color = BG_COLOR

	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _physics_process(_delta: float) -> void:
	if text.is_empty():
		return

	_update_position()


func _draw() -> void:
	if text.is_empty():
		return

	var font: Font = get_theme_font("font")
	var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE)

	_draw_background(text_size)
	_draw_text(text_size, font)


func _update_position() -> void:
	position = _overhead_anchor + Vector2(0, OFFSET_Y)


func _draw_background(text_size: Vector2) -> void:
	var width: float = text_size.x + PADDING_X * 2.0
	var height: float = text_size.y + PADDING_Y * 2.0
	var rect: Rect2 = Rect2(-width / 2.0, -height, width, height)

	draw_style_box(_style_box, rect)


func _draw_text(text_size: Vector2, font: Font) -> void:
	var ascent: float = font.get_ascent(FONT_SIZE)
	var height: float = text_size.y + PADDING_Y * 2.0

	var text_pos: Vector2 = Vector2(
		-text_size.x / 2.0,
		-height + (height - text_size.y) / 2.0 + ascent
	)

	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, TEXT_COLOR)
