extends Node
class_name ChatHandler


func register() -> Error:
	return Network.register([
		chat_local,
		chat_global,
	])


func unregister() -> Error:
	return Network.unregister([
		chat_local,
		chat_global,
	])


func chat_local(sender_name: String, message: String) -> void:
	_add_message(sender_name, message, "local")


func chat_global(sender_name: String, message: String) -> void:
	_add_message(sender_name, message, "global")


func _add_message(sender_name: String, message: String, type: String) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var game: Scene = main.current_scene
	if game == null:
		return

	var chat: ChatInterface = game.get_interface(&"Chat")
	if chat == null:
		return

	var color: String = _get_color_for_type(type)
	var formatted: String = "[color=%s][%s] %s: [/color]%s" % [
		color,
		type.to_upper(),
		sender_name,
		message,
	]

	chat.add_message(formatted)


func _get_color_for_type(type: String) -> String:
	match type:
		"global":
			return "#FFD700"
		"local":
			return "#00FF00"
		_:
			return "#FFFFFF"
