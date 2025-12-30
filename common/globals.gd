extends Node

var rpc: Rpc


func _process(_delta: float) -> void:
	if not rpc:
		return

	rpc.poll()
