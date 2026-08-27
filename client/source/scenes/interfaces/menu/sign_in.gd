extends PanelContainer
class_name SignInInterface


var _main: Main


func _ready() -> void:
	_main = get_tree().root.get_node("./Main")


func _on_close_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	var confirmation: ConfirmationInterface = menu.get_interface(&"Confirmation")
	confirmation.setup("Sair do jogo?")

	confirmation.confirmed.connect(
		func() -> void:
			get_tree().quit()
	, CONNECT_ONE_SHOT)

	confirmation.canceled.connect(
		func() -> void:
			menu.hide_interface(&"Confirmation")
	, CONNECT_ONE_SHOT)

	menu.show_interface(&"Confirmation")


func _on_sign_in_pressed() -> void:
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

	if email.is_empty():
		alert.setup("Informe o e-mail e tente novamente!")
		menu.show_interface(&"Alert")
		return

	if password.is_empty():
		alert.setup("Informe a senha e tente novamente!")
		menu.show_interface(&"Alert")
		return

	Network.exec(&"sign_in", [
		email, password, Constants.MAJOR_VERSION, Constants.MINOR_VERSION, Constants.REVISION_VERSION
	])


func _on_sign_up_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	menu.show_interface(&"SignUp")
	menu.hide_interface(&"SignIn")
