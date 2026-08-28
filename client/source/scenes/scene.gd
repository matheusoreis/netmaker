extends Node2D
class_name Scene


## Categoria de configuração das interfaces.
@export_category("Controls")
## Dicionário de interfaces da cena indexadas por identificador.
@export var _interfaces: Dictionary[StringName, Control]


## Adiciona uma interface à cena.
func add_interface(identifier: StringName, interface: Control) -> void:
	if is_instance_valid(interface) == false:
		return

	if _interfaces.has(identifier):
		return

	_interfaces[identifier] = interface


## Remove uma interface da cena.
func remove_interface(identifier: StringName) -> void:
	var interface: Control = get_interface(identifier)
	if interface == null:
		return

	_interfaces.erase(identifier)
	interface.queue_free()


## Retorna uma interface pelo seu identificador.
func get_interface(identifier: StringName) -> Control:
	return _interfaces.get(identifier, null)


## Alterna a visibilidade de uma interface.
func toggle_interface(identifier: StringName) -> void:
	var interface: Control = get_interface(identifier)
	if interface == null:
		return

	interface.visible = not interface.visible


## Mostra uma interface.
func show_interface(identifier: StringName) -> void:
	var interface: Control = get_interface(identifier)
	if interface == null:
		return

	interface.visible = true


## Esconde uma interface.
func hide_interface(identifier: StringName) -> void:
	var interface: Control = get_interface(identifier)
	if interface == null:
		return

	interface.visible = false
