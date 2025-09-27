extends Node2D
class_name Client


@export_category("General")
@export var client_name: String = "NetMaker"

@export_category("Settings")
@export var host: String = "127.0.0.1"
@export var port: int = 7001


var _network: NetworkClient


func _enter_tree() -> void:
	_network = NetworkClient.new()


func _ready() -> void:
	var err: Error = _network.start(host, port)
	if err == Error.OK:
		print("[CLIENT] Conectando em %s:%d..." % [host, port])


func _process(_delta: float) -> void:
	_network.process()


func register_handlers(handlers: Array) -> void:
	_network.register_handlers(handlers)


func send(packet: Array) -> void:
	_network.send(packet)
