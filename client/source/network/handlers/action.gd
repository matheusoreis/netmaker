extends Node
class_name ActionHandler


func register() -> Error:
	return Network.register([
		alert,
		confirmation,
		ammount
	])


func unregister() -> Error:
	return Network.unregister([
		alert,
		confirmation,
		ammount
	])


func alert(code: String) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var scene: Scene = main.current_scene
	if scene == null:
		return

	# TODO: Mostrar a mensagem

	scene.show_interface(&"Alert")


func confirmation(code: String) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var scene: Scene = main.current_scene
	if scene == null:
		return

	# TODO: Mostrar a mensagem

	scene.show_interface(&"Confirmation")


func ammount(code: String) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var scene: Scene = main.current_scene
	if scene == null:
		return

	# TODO: Mostrar a mensagem

	scene.show_interface(&"Ammount")
