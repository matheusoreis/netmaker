extends PanelContainer
class_name SignInInterface


## Referência ao nó principal do jogo.
var _main: Main


## Inicializa a interface.
func _ready() -> void:
	_main = get_tree().root.get_node("./Main")


## Exibe um alerta no menu informado.
func _show_alert(menu: Menu, message: String) -> void:
	var alert: AlertInterface = menu.get_interface(&"Alert")

	alert.confirmed.connect(func() -> void:
		menu.hide_interface(&"Alert")
	, CONNECT_ONE_SHOT)

	alert.setup(message)
	menu.show_interface(&"Alert")


## Valida as credenciais de login.
func _validate_credentials(email: String, password: String) -> String:
	if email.is_empty():
		return "Informe o e-mail e tente novamente!"

	if password.is_empty():
		return "Informe a senha e tente novamente!"

	return ""


## Fecha a interface e sai do jogo.
func _on_close_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	var confirmation: ConfirmationInterface = menu.get_interface(&"Confirmation")
	confirmation.setup("Sair do jogo?")

	confirmation.confirmed.connect(func() -> void:
		get_tree().quit()
	, CONNECT_ONE_SHOT)

	confirmation.canceled.connect(func() -> void:
		menu.hide_interface(&"Confirmation")
	, CONNECT_ONE_SHOT)

	menu.show_interface(&"Confirmation")


## Processa o login do usuário.
func _on_sign_in_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	var email: String = %Email.text
	var password: String = %Password.text

	var error: String = _validate_credentials(email, password)
	if not error.is_empty():
		_show_alert(menu, error)
		return

	Network.exec(&"sign_in", [
		email, password, Constants.MAJOR_VERSION, Constants.MINOR_VERSION, Constants.REVISION_VERSION
	])


## Abre a interface de cadastro.
func _on_sign_up_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	menu.show_interface(&"SignUp")
	menu.hide_interface(&"SignIn")
