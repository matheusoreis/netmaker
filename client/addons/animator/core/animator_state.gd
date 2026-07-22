extends RefCounted
class_name AnimatorState


var name: String = ""
var playing: bool = false
var should_finish: bool = false
var first: int = 0
var last: int = 0
var fps: float = 6.0
var loop: bool = true
var current_frame: int = 0
var accumulator: float = 0.0

func setup(data: AnimatorData, anim_name: String) -> void:
	name = anim_name
	first = data.first
	last = data.last
	fps = data.fps
	loop = data.loop
	should_finish = false
	playing = true


func needs_reset() -> bool:
	return current_frame < first or current_frame > last


func reset() -> void:
	current_frame = first
	accumulator = 0.0


func tick(delta: float, frame_duration: float) -> bool:
	accumulator += delta
	return accumulator >= frame_duration


func consume_frame() -> void:
	accumulator -= (1.0 / fps)


func stop() -> void:
	playing = false
	should_finish = false
	accumulator = 0.0


func finish_now() -> void:
	current_frame = first
	playing = false
	should_finish = false


func is_playing(anim_name: String = "") -> bool:
	if anim_name == "":
		return playing
	return playing and name == anim_name
