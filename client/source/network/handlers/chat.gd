extends Node
class_name ChatHandler


## Registra as funções remotas relacionadas ao chat.
func register() -> Error:
	return Network.register([
		chat_local,
		chat_global,
	])


## Desregistra as funções remotas relacionadas ao chat.
func unregister() -> Error:
	return Network.unregister([
		chat_local,
		chat_global,
	])


## Adiciona uma mensagem local ao chat.
func chat_local(sender_name: String, message: String) -> void:
	_add_message(sender_name, message, "local")


## Adiciona uma mensagem global ao chat.
func chat_global(sender_name: String, message: String) -> void:
	_add_message(sender_name, message, "global")


## Adiciona uma mensagem formatada ao chat.
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


## Retorna a cor correspondente ao tipo de mensagem.
func _get_color_for_type(type: String) -> String:
	match type:
		"global":
			return "#FFD700"
		"local":
			return "#00FF00"
		_:
			return "#FFFFFF"
