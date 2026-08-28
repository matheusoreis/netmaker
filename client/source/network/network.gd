extends Node


## Sinal emitido quando a conexão é estabelecida.
signal connected()
## Sinal emitido quando a conexão é perdida.
signal disconnected()


## Cliente de rede responsável pela comunicação.
var network: Multiplayer.Client


## Inicializa o cliente de rede e conecta seus sinais.
func _init() -> void:
	network = Multiplayer.Client.new()

	network.connected.connect(
		func() -> void:
			connected.emit()
	)

	network.disconnected.connect(
		func() -> void:
			disconnected.emit()
	)


## Processa os eventos de rede a cada quadro.
func _physics_process(_delta: float) -> void:
	if network:
		network.poll()


## Inicia a conexão com o servidor.
func start(host: String, port: int) -> Error:
	return network.start(host, port)


## Para a conexão com o servidor.
func stop() -> Error:
	return await network.stop()


## Registra funções remotas no servidor.
func register(remote_funcs: Array[Callable]) -> Error:
	return network.register(remote_funcs)


## Desregistra funções remotas do servidor.
func unregister(remote_funcs: Array[Callable]) -> Error:
	return network.unregister(remote_funcs)


## Executa uma função remota no servidor.
func exec(fn_path: StringName, args: Array = []) -> Error:
	return network.exec(fn_path, args)
