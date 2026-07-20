extends Node2D
class_name Main


func _ready() -> void:
	Network.client_connected.connect(
		_on_client_connected
	)

	Network.client_disconnected.connect(
		_on_client_disconnected
	)

	_load_data()

	if not setup_network():
		push_error("[MAIN] Falha ao iniciar o servidor de rede.")
		return

	if not setup_handler():
		push_error("[MAIN] Falha ao registrar os handlers.")
		return


func _physics_process(_delta: float) -> void:
	Network.poll()


func _load_data() -> void:
	GameMaps.load_all()


func setup_network() -> bool:
	print("[NETWORK] Iniciando servidor em %s:%d (máx. %d clientes)..." % [
		Constants.HOST,
		Constants.PORT,
		Constants.MAX_PEERS,
	])

	var err: Error = Network.start(
		Constants.HOST,
		Constants.PORT,
		Constants.MAX_PEERS,
	)

	if err != OK:
		push_error("[NETWORK] Erro ao iniciar o servidor (%s)." % error_string(err))
		return false

	print("[NETWORK] Servidor iniciado com sucesso!")
	return true


func setup_handler() -> bool:
	print("[HANDLER] Registrando handlers...")

	var error: Error = Handler.setup()
	if error != OK:
		push_error("[HANDLER] Erro ao registrar (%s)." % error_string(error))
		return false

	print("[HANDLER] Handlers registrados com sucesso!")
	return true


func _on_client_connected(peer_id: int) -> void:
	print("[NETWORK] Cliente %d conectado." % peer_id)


func _on_client_disconnected(peer_id: int) -> void:
	print("[NETWORK] Cliente %d desconectado." % peer_id)

	var actor: Actor = GameActors.actor(peer_id)
	if not actor:
		return

	Sender.left(peer_id)

	GameMaps.remove_occupant(actor.map_id, actor.map_position, peer_id)
	GameActors.remove(peer_id)
