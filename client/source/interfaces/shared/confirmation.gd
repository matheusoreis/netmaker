extends PanelContainer
class_name ConfirmationInterface


## Sinal emitido quando o botão de confirmação é pressionado.
signal confirmed()
## Sinal emitido quando o botão de cancelamento é pressionado.
signal canceled()


## Configura a mensagem da confirmação.
func setup(message: String) -> void:
	%Message.text = message


## Processa o pressionamento do botão de confirmação.
func _on_confirm_pressed() -> void:
	confirmed.emit()


## Processa o pressionamento do botão de cancelamento.
func _on_cancel_pressed() -> void:
	canceled.emit()
