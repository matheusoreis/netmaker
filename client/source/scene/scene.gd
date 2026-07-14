extends Node2D
class_name Scene


@export var controls: Dictionary[StringName, Control] = {}


func _ready() -> void:
	_register_exported_controls()


func _register_exported_controls() -> void:
	for identifier: StringName in controls.keys():
		var node: Control = controls[identifier]

		if not is_instance_valid(node):
			push_warning("Scene: Control '%s' is not a valid Control node" % identifier)
			continue

		if controls.has(identifier):
			continue

		add_control(identifier, node)


func add_control(identifier: StringName, node: Control) -> bool:
	if controls.has(identifier):
		push_warning("Scene: Control '%s' already exists" % identifier)
		return false

	if not is_instance_valid(node):
		push_warning("Scene: Invalid node for control '%s'" % identifier)
		return false

	controls[identifier] = node
	return true


func read_control(identifier: StringName) -> Control:
	return controls.get(identifier, null)


func show_control(identifier: StringName) -> void:
	var control: Control = read_control(identifier)

	if control == null:
		push_warning("Scene: Control '%s' not found" % identifier)
		return

	control.show()


func hide_control(identifier: StringName) -> void:
	var control: Control = read_control(identifier)

	if control == null:
		push_warning("Scene: Control '%s' not found" % identifier)
		return

	control.hide()


func toggle_control(identifier: StringName) -> void:
	var control: Control = read_control(identifier)

	if control == null:
		push_warning("Scene: Control '%s' not found" % identifier)
		return

	control.visible = not control.visible


func hide_all_controls() -> void:
	for control in controls.values():
		if not is_instance_valid(control):
			continue

		control.hide()


func show_all_controls() -> void:
	for control in controls.values():
		if not is_instance_valid(control):
			continue

		control.show()


func get_control(identifier: StringName) -> Control:
	return read_control(identifier)


func has_control(identifier: StringName) -> bool:
	return controls.has(identifier)


func remove_control(identifier: StringName) -> void:
	if not controls.erase(identifier):
		return

	push_warning("Scene: Control '%s' removed" % identifier)


func clear_controls() -> void:
	controls.clear()


func get_control_count() -> int:
	return controls.size()
