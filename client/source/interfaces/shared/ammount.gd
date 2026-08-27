extends PanelContainer
class_name AmmountInterface


signal confirmed(value: int)
signal canceled()


func setup(message: String, min_value: int = 0, max_value: int = 100) -> void:
	%Message.text = message

	%Ammount.min_value = min_value
	%Ammount.max_value = max_value


func _on_confirm_pressed() -> void:
	confirmed.emit(%Ammount.value)


func _on_cancel_pressed() -> void:
	canceled.emit()
