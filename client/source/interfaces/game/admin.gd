extends PanelContainer
class_name Admin


## Referência ao nó principal do jogo.
var _main: Main


## Inicializa a interface administrativa.
func _ready() -> void:
	_main = get_tree().root.get_node("./Main")


## Exibe uma confirmação antes de executar uma ação.
func _show_confirmation(game: Game, message: String, confirmed: Callable) -> void:
	var confirmation: ConfirmationInterface = game.get_interface(&"Confirmation")

	confirmation.confirmed.connect(
		confirmed
	,CONNECT_ONE_SHOT)

	confirmation.canceled.connect(func() -> void:
		game.hide_interface(&"Confirmation")
	, CONNECT_ONE_SHOT)

	confirmation.setup(message)
	game.show_interface(&"Confirmation")


## Fecha a interface administrativa.
func _on_close_pressed() -> void:
	var game: Game = _main.current_scene
	if game == null:
		return

	game.hide_interface(&"Admin")


## Envia as atualizações do mapa para o servidor.
func _on_update_map_pressed() -> void:
	var game: Game = _main.current_scene
	if game == null:
		return

	_show_confirmation(game, "Enviar o mapa ao servidor?",
		func() -> void:
			var map: Map = game.current_map

			var collisions: Array = map.export_collisions()
			var warps: Array = map.export_warps()

			Network.exec(&"update_map", [map.identifier, map.bgm, map.bgs, map.size, collisions, warps])
			game.hide_interface(&"Confirmation")
	)
