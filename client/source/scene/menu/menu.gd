extends Scene
class_name MenuScene


func _ready() -> void:
	super()

	var map_scene: PackedScene = load("res://source/gameplay/map/map.tscn")
	var map: Map = map_scene.instantiate()
	map.setup(1, "Floresta", Vector2i(1, 1), Vector2i.DOWN, 24, 18)

	add_child(map)

	GameSystem.add_map(map)

	var actor: Actor = Actor.new(1, "Raizen", "fighter01", 4, 4, map.start_position, map.start_direction)
	actor.name = "Actor1"

	GameSystem.add_actor(actor)

	map.add_child(actor)
