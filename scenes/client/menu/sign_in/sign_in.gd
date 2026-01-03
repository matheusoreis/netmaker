extends PanelContainer
class_name SignInUi

@export_category("References")
@export var alert_ui: AlertUi
@export var sign_up_ui: SignUpUi

@export_category("Nodes")
@export var identifier_input: LineEdit
@export var password_input: LineEdit


func _ready() -> void:
	if not validate_dependencies():
		set_process(false)
		return


func validate_dependencies() -> bool:
	var ok := true
	if alert_ui == null:
		push_error("[SignInUi] 'alert_ui' não está atribuído.")
		ok = false
	if sign_up_ui == null:
		push_error("[SignInUi] 'sign_up_ui' não está atribuído.")
		ok = false
	if identifier_input == null:
		push_error("[SignInUi] 'identifier_input' não está atribuído.")
		ok = false
	if password_input == null:
		push_error("[SignInUi] 'password_input' não está atribuído.")
		ok = false
	return ok


func _on_sign_up_pressed() -> void:
	sign_up_ui.show()
	hide()


func _on_sign_in_pressed() -> void:
	var identifier_length: int = Constants.IDENNTIFIER_MIN_LENGTH
	var password_length: int = Constants.PASSWORD_MIN_LENGTH

	if identifier_input.text.find(" ") != -1:
		alert_ui.show_message("O identificador não pode conter espaços.")
		return

	if identifier_input.text.length() <= identifier_length:
		alert_ui.show_message("O identificador deve ter pelo menos %d caracteres." % identifier_length)
		return

	if password_input.text.length() <= password_length:
		alert_ui.show_message("A senha deve ter pelo menos %d caracteres." % password_length)
		return
