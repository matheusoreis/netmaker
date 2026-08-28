extends PanelContainer
class_name SignUpInterface


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


## Valida as credenciais de cadastro.
func _validate_credentials(email: String, password: String, password_confirm: String) -> String:
	if email.is_empty():
		return "Informe o e-mail e tente novamente!"

	if password.is_empty() or password_confirm.is_empty():
		return "Informe as senhas e tente novamente!"

	if password != password_confirm:
		return "As senhas não são iguais, tente novamente!"

	return ""


## Fecha a interface de cadastro.
func _on_close_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	menu.show_interface(&"SignIn")
	menu.hide_interface(&"SignUp")


## Processa o cadastro do usuário.
func _on_sign_up_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	var email: String = %Email.text
	var password: String = %Password.text
	var password_confirm: String = %Password2.text

	var error: String = _validate_credentials(email, password, password_confirm)
	if not error.is_empty():
		_show_alert(menu, error)
		return

	Network.exec(&"sign_up", [
		email, password, password_confirm, Constants.MAJOR_VERSION, Constants.MINOR_VERSION, Constants.REVISION_VERSION
	])
