extends Node2D
class_name Server


@export_category("General")
@export var server_name: String = "NetMaker"

@export_category("Settings")
@export var port: int = 7001
@export var capacity: int = 100

@export_category("Handlers")

@export_category("Modules")
@export var map: MapModule
@export var actor: ActorModule


var _network: NetworkServer

func _enter_tree() -> void:
	_network = NetworkServer.new()


func _ready() -> void:
	_network.peer_connected.connect(_on_peer_connected)
	_network.peer_disconnected.connect(_on_peer_disconnected)

	var err: Error = _network.start(port, capacity)
	if err == Error.OK:
		print("[SERVER] Rodando na porta %d, com capacidade de %d clientes." % [port, capacity])


func _process(_delta: float) -> void:
	_network.process()


func _on_peer_connected(peer: ENetPacketPeer) -> void:
	print("[SERVER] Cliente conectado:", peer.get_instance_id())


func _on_peer_disconnected(peer: ENetPacketPeer) -> void:
	print("[SERVER] Cliente desconectado:", peer.get_instance_id())


func register_handlers(handlers: Array) -> void:
	_network.register_handlers(handlers)


func _send(filter: Callable, packet: Array) -> void:
	var data := var_to_bytes(packet)
	for peer in _network.get_peers():
		if not filter.call(peer):
			continue
		if peer.get_state() != ENetPacketPeer.STATE_CONNECTED:
			continue

		peer.send(0, data, ENetPacketPeer.FLAG_RELIABLE)


func send_to(peer: ENetPacketPeer, packet: Array) -> void:
	_send(func(p): return p == peer, packet)


func send_to_all(packet: Array) -> void:
	_send(func(_p): return true, packet)


func send_to_all_but(exclude: ENetPacketPeer, packet: Array) -> void:
	_send(func(p): return p != exclude, packet)


func send_to_list(peers: Array[ENetPacketPeer], packet: Array) -> void:
	_send(func(p): return peers.has(p), packet)


func send_to_map(map_id: int, packet: Array) -> void:
	_send(func(peer): return actor.is_in_map(peer, map_id), packet)


func send_to_map_but(map_id: int, exclude: ENetPacketPeer, packet: Array) -> void:
	_send(func(peer): return peer != exclude and actor.is_in_map(peer, map_id), packet)
