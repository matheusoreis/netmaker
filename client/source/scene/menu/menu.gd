extends Scene
class_name Menu


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		GameScenes.push_scene("game")
