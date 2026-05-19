extends Control
class_name BootScene


func _on_client_button_pressed() -> void:
	get_tree().change_scene_to_file("res://client/scenes/main.tscn")


func _on_server_button_pressed() -> void:
	get_tree().change_scene_to_file("res://server/scenes/server.tscn")
