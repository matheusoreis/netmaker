extends RefCounted
class_name AnimatorData

var first: int
var last: int
var fps: float
var loop: bool


func _init(first: int, last: int, fps: float = 6.0, loop: bool = true) -> void:
	self.first = first
	self.last = last
	self.fps = fps
	self.loop = loop


func frame_duration() -> float:
	return 1.0 / fps


func is_valid_frame(frame: int) -> bool:
	return frame >= first and frame <= last


func clamp_frame(frame: int) -> int:
	if frame < first:
		return first
	if frame > last:
		return last
	return frame


func next_frame(current: int) -> int:
	var next := current + 1
	if next > last:
		return first if loop else last
	return next


func is_last_frame(frame: int) -> bool:
	return frame == last
