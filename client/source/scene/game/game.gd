extends Scene
class_name Game


func _ready() -> void:
	super()

	Network.exec(&"join", ["Raizen", "fighter01"])
#
	#GameMaps.load_map("01")
#
	#var map: Map = GameMaps.read_map()
	#if map == null:
		#return
#
	#var actor: Actor = Actor.new(1, "Raizen", "fighter01", 4, 4, map.start_position, map.start_direction)
	#actor.name = "Actor1"
#
	#GameActors.add_actor(actor)
	#GameActors.actor_id = 1
#
	#actor.write_is_local(true if GameActors.actor_id == actor.id else false)
#
	#add_child(map)
	#map.add_child(actor)
#
	#actor.setup_camera(map)
