extends PanelContainer
class_name AlertInterface


## Sinal emitido quando o botão de confirmação é pressionado.
signal confirmed()


## Configura a mensagem do alerta.
func setup(message: String) -> void:
	%Message.text = message


## Processa o pressionamento do botão de confirmação.
func _on_confirm_pressed() -> void:
	confirmed.emit()
