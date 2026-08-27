extends PanelContainer
class_name SignUpInterface


var _main: Main


func _ready() -> void:
	_main = get_tree().root.get_node("./Main")


func _on_close_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	menu.show_interface(&"SignIn")
	menu.hide_interface(&"SignUp")


func _on_sign_up_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	var alert: AlertInterface = menu.get_interface(&"Alert")

	alert.confirmed.connect(
		func() -> void:
			menu.hide_interface(&"Alert")
	, CONNECT_ONE_SHOT)

	var email: String = %Email.text
	var password: String = %Password.text
	var password2: String = %Password2.text

	if email.is_empty():
		alert.setup("Informe o e-mail e tente novamente!")
		menu.show_interface(&"Alert")
		return

	if password.is_empty() or password2.is_empty():
		alert.setup("Informe as senhas e tente novamente!")
		menu.show_interface(&"Alert")
		return

	if password != password2:
		alert.setup("As senhas não são iguais, tente novamente!")
		menu.show_interface(&"Alert")
		return

	Network.exec(&"sign_up", [
		email, password, password2, Constants.MAJOR_VERSION, Constants.MINOR_VERSION, Constants.REVISION_VERSION
	])
