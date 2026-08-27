extends Node
class_name AuthHandler


func register() -> Error:
	return Network.register([
		sign_in,
		sign_up
	])


func unregister() -> Error:
	return Network.unregister([
		sign_in,
		sign_up
	])


func sign_in() -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var menu: Menu = main.current_scene
	if menu == null:
		return

	Network.exec(&"list_characters")

	menu.hide_interface(&"SignIn")
	menu.show_interface(&"CharacterSelection")


func sign_up() -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var menu: Menu = main.current_scene
	if menu == null:
		return

	Network.exec(&"list_characters")

	menu.hide_interface(&"SignUp")
	menu.show_interface(&"CharacterSelection")
