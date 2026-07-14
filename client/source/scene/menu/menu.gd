extends Scene
class_name MenuScene


func _ready() -> void:
	super()

	var map: Map = Map.new(1, "Floresta", Vector2i(1, 1), Vector2i.DOWN, 24, 18)
	map.name = "Map1"
	add_child(map)

	GameSystem.add_map(map)

	var actor: Actor = Actor.new(1, "Raizen", "fighter01", 4, 4, 1, map.start_position, map.start_direction)
	actor.name = "Actor1"

	GameSystem.add_actor(actor)

	map.add_child(actor)
