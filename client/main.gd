extends Control


func _ready() -> void:
	var error: Error = Network.create_client()
	if error != OK:
		return
