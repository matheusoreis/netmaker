extends Node
class_name CharacterHandler


func register() -> Error:
	return Network.register([
		list_characters,
		create_character,
		delete_character,
		select_character
	])


func unregister() -> Error:
	return Network.unregister([
		list_characters,
		create_character,
		delete_character,
		select_character
	])


func list_characters(characters: Array) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var menu: Menu = main.current_scene
	if menu == null:
		return

	var selection: CharacterSelection = menu.get_interface(&"CharacterSelection")
	selection.update_characters(characters)

	menu.hide_interface(&"CharacterCreation")
	menu.show_interface(&"CharacterSelection")


func create_character() -> void:
	Network.exec(&"list_characters")


func delete_character() -> void:
	Network.exec(&"list_characters")


func select_character() -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	main.go_to_game()
