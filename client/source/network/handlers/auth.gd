extends Node
class_name AuthHandler


## Registra as funções remotas relacionadas a autenticação.
func register() -> Error:
	return Network.register([
		sign_in,
		sign_up
	])


## Desregistra as funções remotas relacionadas a autenticação.
func unregister() -> Error:
	return Network.unregister([
		sign_in,
		sign_up
	])


## Processa o login bem-sucedido e exibe a seleção de personagens.
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


## Processa o cadastro bem-sucedido e exibe a seleção de personagens.
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
