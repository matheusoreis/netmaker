extends PanelContainer
class_name ChatInterface


## Opacidade do painel quando o chat está focado.
const FOCUSED_OPACITY: float = 0.8
## Opacidade do painel quando o chat não está focado.
const UNFOCUSED_OPACITY: float = 0.4


## Referência ao nó principal do jogo.
var _main: Main
## Estilo do painel para ajuste de opacidade.
var _panel_style: StyleBoxFlat


## Inicializa a interface do chat.
func _ready() -> void:
	_main = get_tree().root.get_node("./Main")


## Adiciona uma mensagem ao histórico do chat.
func add_message(text: String) -> void:
	while %History.get_line_count() >= 100:
		%History.remove_line(0)

	%History.append_text(text + "\n")
	%History.scroll_to_line(%History.get_line_count() - 1)


## Envia a mensagem digitada.
func _on_send_pressed() -> void:
	var text: String = %Message.text
	if text.is_empty():
		return

	_on_message_text_submitted(text)
	%Message.text = ""


## Processa o envio de uma mensagem.
func _on_message_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		return

	if new_text.begins_with("/"):
		_handle_command(new_text)
		%Message.release_focus()
		return

	Network.exec(&"chat_local", [new_text])
	%Message.clear()
	%Message.release_focus()


## Processa comandos do chat.
func _handle_command(text: String) -> void:
	var parts: Array = text.split(" ", false)
	var command: String = parts[0].to_lower()

	match command:
		"/global", "/g":
			var message: String = text.substr(parts[0].length() + 1)
			if not message.is_empty():
				Network.exec(&"chat_global", [message])
				%Message.clear()

		"/local", "/l":
			var message: String = text.substr(parts[0].length() + 1)
			if not message.is_empty():
				Network.exec(&"chat_local", [message])
				%Message.clear()

		"/help", "/?":
			_show_help()
			%Message.clear()
		_:
			add_message("[color=#FF6B6B]Comando desconhecido: %s[/color]" % command)
			%Message.clear()


## Exibe a lista de comandos disponíveis.
func _show_help() -> void:
	add_message("[color=#FFFFFF]/global ou /g [mensagem] - Mensagem global[/color]")
	add_message("[color=#FFFFFF]/local ou /l [mensagem] - Mensagem local (mesmo mapa)[/color]")
	add_message("[color=#FFFFFF]/help ou /? - Mostra esta ajuda[/color]")


## Fecha a interface do chat.
func _on_close_pressed() -> void:
	hide()


## Aumenta a opacidade ao focar no campo de mensagem.
func _on_message_focus_entered() -> void:
	var game: Game = _main.current_scene
	if game == null:
		return

	game.chat_active = true

	if _panel_style != null:
		_panel_style.bg_color.a = FOCUSED_OPACITY


## Diminui a opacidade ao perder o foco no campo de mensagem.
func _on_message_focus_exited() -> void:
	var game: Game = _main.current_scene
	if game == null:
		return

	game.chat_active = false

	if _panel_style != null:
		_panel_style.bg_color.a = UNFOCUSED_OPACITY
