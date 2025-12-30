extends Node2D
class_name Boot


func _on_server_pressed() -> void:
	var scene: PackedScene = load("res://scenes/server/server.tscn")
	get_tree().change_scene_to_packed(
		scene
	)


func _on_client_pressed() -> void:
	var scene: PackedScene = load("res://scenes/client/client.tscn")
	get_tree().change_scene_to_packed(
		scene
	)
