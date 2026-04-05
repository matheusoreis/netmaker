extends RefCounted
class_name Stopwatch


enum Unit {
	S,
	MS,
	US,
}


const PADDING: int = 30


var _label: String
var _unit: Unit
var _start: int


func _init(label: String, unit: Unit = Unit.S) -> void:
	_label = label
	_unit = unit
	_start = Time.get_ticks_usec()


func restart() -> void:
	_start = Time.get_ticks_usec()


func step(tag: String = "") -> void:
	var elapsed: int = Time.get_ticks_usec() - _start
	var text: String = _label + ("" if tag == "" else " / " + tag)
	match _unit:
		Unit.S:
			print("%s %.2fs" % [text.rpad(PADDING), elapsed / 1_000_000.0])
		Unit.MS:
			print("%s %.2fms" % [text.rpad(PADDING), elapsed / 1_000.0])
		Unit.US:
			print("%s %dus" % [text.rpad(PADDING), elapsed])
	_start = Time.get_ticks_usec()
