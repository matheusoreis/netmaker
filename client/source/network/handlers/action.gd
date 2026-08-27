extends Node
class_name ActionHandler


func register() -> Error:
	return Network.register([
		alert,
		confirmation,
	])


func unregister() -> Error:
	return Network.unregister([
		alert,
		confirmation,
	])


func alert(code: String) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var scene: Scene = main.current_scene
	if scene == null:
		return

	var alert: AlertInterface = scene.get_interface(&"Alert")
	alert.setup(tr(code))

	scene.show_interface(&"Alert")

	alert.confirmed.connect(
		func() -> void: scene.hide_interface(&"Alert")
	, CONNECT_ONE_SHOT)


func confirmation(code: String) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var scene: Scene = main.current_scene
	if scene == null:
		return

	var alert: ConfirmationInterface = scene.get_interface(&"Confirmation")
	alert.setup(tr(code))

	scene.show_interface(&"Confirmation")
