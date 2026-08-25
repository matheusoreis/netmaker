extends Node
class_name Network


## Emitido quando um jogador se conecta.
signal peer_connected(peer_id: int)

## Emitido quando um jogador se desconecta.
signal peer_disconnected(peer_id: int)


## Gerencia a comunicação de rede do servidor.
var _network: Multiplayer.Server


## Inicializa a rede e conecta os sinais do servidor.
func _init() -> void:
	_network = Multiplayer.Server.new()

	_network.peer_connected.connect(
		func(peer_id: int) -> void:
			peer_connected.emit(peer_id)
	)

	_network.peer_disconnected.connect(
		func(peer_id: int) -> void:
			peer_disconnected.emit(peer_id)
	)


## Inicia o servidor.
func start(host: String, port: int, max_peers: int) -> Error:
	return _network.start(host, port, max_peers)


## Para o servidor.
func stop() -> Error:
	return _network.stop()


## Registra funções que podem ser chamadas remotamente.
func register(remote_funcs: Array[Callable]) -> Error:
	return _network.register(remote_funcs)


## Remove funções registradas para chamadas remotas.
func unregister(remote_funcs: Array[Callable]) -> Error:
	return _network.unregister(remote_funcs)


## Executa uma função remotamente.
func exec(target: Variant, function: StringName, args: Array = []) -> Error:
	return _network.exec(target, function, args)


## Retorna os IDs dos peers conectados.
func get_peers() -> Array[int]:
	return _network.get_peers()


## Retorna o número de peers conectados.
func get_peer_count() -> int:
	return _network.get_peer_count()


## Verifica se um jogador está conectado.
func has_peer(peer_id: int) -> bool:
	return _network.has_peer(peer_id)


## Retorna o id do jogador que enviou a chamada atual.
func sender_id() -> int:
	return _network.sender_id()


## Retorna o endereço de rede de um jogador.
func peer_address(peer_id: int) -> String:
	return _network.peer_address(peer_id)


## Remove um jogador do servidor.
func kick(peer_id: int) -> void:
	_network.kick(peer_id)


## Processa as mensagens pendentes da rede.
func poll() -> void:
	_network.poll()
