extends Node2D
class_name Server


@export_category("General")
@export var server_name: String = "NetMaker"


@export_category("Settings")
@export var port: int = 7001
@export var capacity: int = 100


var _network: NetworkServer


func _enter_tree() -> void:
	_network = NetworkServer.new()


func _ready() -> void:
	_network.peer_connected.connect(_on_peer_connected)
	_network.peer_disconnected.connect(_on_peer_disconnected)

	var err: Error = _network.start(port, capacity)
	if err == Error.OK:
		print("[SERVER] Rodando na porta %d, com capacidade de %d clientes." % [port, capacity])


func _on_peer_connected(peer: ENetPacketPeer) -> void:
	print("[SERVER] Cliente conectado:", peer.get_instance_id())


func _on_peer_disconnected(peer: ENetPacketPeer) -> void:
	print("[SERVER] Cliente desconectado:", peer.get_instance_id())
