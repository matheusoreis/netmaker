extends Node2D
class_name Boot


@export_category("Scenes")
@export var client: PackedScene
@export var server: PackedScene


func _on_client_pressed() -> void:
	get_tree().change_scene_to_packed(client)


func _on_server_pressed() -> void:
	get_tree().change_scene_to_packed(server)
