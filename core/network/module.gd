extends Node
class_name RpcModule

@export_category("Settings")
@export var scope: String

var server: Rpc.Server


func initialize(rpc: Rpc) -> void:
	if rpc != Rpc.Server:
		print("[RPC] Falha ao iniciar o módulo, o RPC não é o servidor.")
		return

	server = rpc

	var module_name: String = get_script().get_global_name()
	print("[RPC] Iniciando o módulo %s no escopo %s" % [module_name, scope])

	server.register(scope, _get_methods())

	print("[RPC] Módulo %s iniciado." % module_name)


func _get_methods() -> Array[Callable]:
	return []
