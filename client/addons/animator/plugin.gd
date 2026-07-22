@tool
extends EditorPlugin


const animator: GDScript = preload("res://addons/animator/core/animator.gd")


func _enter_tree() -> void:
	add_custom_type(
		"Animator",
		"Node2D",
		animator,
		null
	)


func _exit_tree() -> void:
	remove_custom_type("Animator")
