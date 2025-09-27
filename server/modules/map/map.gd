class_name MapModule extends Node


@export_category("Settings")
@export var maps_location: Node

var _maps: Dictionary


func add(scenes: Array[PackedScene]) -> void:
	for scene in scenes:
		var instance = scene.instantiate()

		if not instance is Map:
			print("[CLIENT] Scene %s não é do tipo Map" % scene.resource_path)
			continue

		var map_id: int = instance.id

		if _maps.has(map_id):
			print("[CLIENT] Map ID %d já registrado, ignorando duplicata." % map_id)
			continue

		_maps[map_id] = instance
		maps_location.add_child(instance)


func read(map_id: int) -> Map:
	return _maps.get(map_id, null)


func read_all() -> Array[Map]:
	return _maps.values()
