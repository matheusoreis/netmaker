extends PanelContainer
class_name AlertInterface


signal confirmed()


func setup(message: String) -> void:
	%Message.text = message


func _on_confirm_pressed() -> void:
	confirmed.emit()
