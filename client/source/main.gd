extends Node2D
class_name Main


func _ready() -> void:
	GameScenes.load_scene("menu")

	Network.connected.connect(
		_on_client_connected
	)

	Network.disconnected.connect(
		_on_client_disconnected
	)

	if not setup_network():
		push_error("[MAIN] Falha ao iniciar o cliente.")
		return

	if not setup_handler():
		push_error("[MAIN] Falha ao registrar os handlers.")
		return


func _physics_process(_delta: float) -> void:
	Network.poll()


func setup_network() -> bool:
	print("[NETWORK] Iniciando cliente em %s:%d..." % [
		Constants.HOST,
		Constants.PORT,
	])

	var err: Error = Network.start(
		Constants.HOST,
		Constants.PORT,
	)

	if err != OK:
		push_error("[NETWORK] Erro ao iniciar o cliente (%s)." % error_string(err))
		return false

	print("[NETWORK] Cliente iniciado com sucesso!")
	return true


func setup_handler() -> bool:
	print("[HANDLER] Registrando handlers...")

	var error: Error = Handler.setup()
	if error != OK:
		push_error("[HANDLER] Erro ao registrar (%s)." % error_string(error))
		return false

	print("[HANDLER] Handlers registrados com sucesso!")
	return true


func _on_client_connected() -> void:
	print("[NETWORK] Cliente conectado.")


func _on_client_disconnected() -> void:
	print("[NETWORK] Cliente desconectado.")
