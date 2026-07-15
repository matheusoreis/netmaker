extends Scene
class_name MenuScene


func _ready() -> void:
	super()

	GameMaps.load_map("01")

	var map: Map = GameMaps.read_map()
	if map == null:
		return

	var actor: Actor = Actor.new(1, "Raizen", "monster13", 4, 4, map.start_position, map.start_direction)
	actor.name = "Actor1"

	GameActors.add_actor(map, actor)
	GameActors.actor_id = 1
