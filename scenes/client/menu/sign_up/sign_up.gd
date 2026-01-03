extends PanelContainer
class_name SignUpUi

@export_category("References")
@export var alert_ui: AlertUi
@export var sign_in_ui: SignInUi

@export_category("Nodes")
@export var user_input: LineEdit
@export var password_input: LineEdit
@export var repassword_input: LineEdit


func _ready() -> void:
	if not validate_dependencies():
		set_process(false)
		return


func validate_dependencies() -> bool:
	var ok := true
	if alert_ui == null:
		push_error("[SignUpUi] 'alert_ui' não está atribuído.")
		ok = false
	if sign_in_ui == null:
		push_error("[SignUpUi] 'sign_in_ui' não está atribuído.")
		ok = false
	if user_input == null:
		push_error("[SignUpUi] 'user_input' não está atribuído.")
		ok = false
	if password_input == null:
		push_error("[SignUpUi] 'password_input' não está atribuído.")
		ok = false
	if repassword_input == null:
		push_error("[SignUpUi] 'repassword_input' não está atribuído.")
		ok = false
	return ok


func _on_sign_in_pressed() -> void:
	sign_in_ui.show()
	hide()


func _on_sign_up_pressed() -> void:
	var identifier_length: int = Constants.IDENNTIFIER_MIN_LENGTH
	var password_length: int = Constants.PASSWORD_MIN_LENGTH

	if user_input.text.find(" ") != -1:
		alert_ui.show_message("O identificador não pode conter espaços.")
		return

	if user_input.text.length() <= identifier_length:
		alert_ui.show_message("O identificador deve ter pelo menos %d caracteres." % identifier_length)
		return

	if password_input.text.length() <= password_length:
		alert_ui.show_message("A senha deve ter pelo menos %d caracteres." % password_length)
		return

	if password_input.text != repassword_input.text:
		alert_ui.show_message("As senhas não coincidem.")
		return
