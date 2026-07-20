extends Node


func join(identifier: String, spritesheet: String) -> void:
	Network.exec("join", [identifier, spritesheet])


func move(direction: Vector2i) -> void:
	Network.exec("move", [direction])


func update_map(map: Map) -> void:
	Network.exec("update_map", [map.id, map.collisions()])
