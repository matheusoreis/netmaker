extends Node
class_name CharacterHandler


## Registra as funções remotas relacionadas a personagens.
func register() -> Error:
	return Network.register([
		list_characters,
		create_character,
		delete_character,
		select_character
	])


## Desregistra as funções remotas relacionadas a personagens.
func unregister() -> Error:
	return Network.unregister([
		list_characters,
		create_character,
		delete_character,
		select_character
	])


## Atualiza a lista de personagens na interface.
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


## Processa a criação de um novo personagem.
func create_character() -> void:
	Network.exec(&"list_characters")


## Processa a exclusão de um personagem.
func delete_character() -> void:
	Network.exec(&"list_characters")


## Processa a seleção de um personagem e entra no jogo.
func select_character() -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	main.go_to_game()
