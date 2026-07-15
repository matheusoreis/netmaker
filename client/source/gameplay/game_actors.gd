extends Node


var _actors: Dictionary[int, Actor] = {}

var actor_id: int = -1


func add_actor(actor: Actor) -> void:
	var id: int = actor.id

	if _actors.has(id):
		return

	_actors[id] = actor


func read_actor(id: int) -> Actor:
	var actor: Actor = _actors.get(id)
	if actor and not is_instance_valid(actor):
		_actors.erase(id)
		return null
	return actor


func remove_actor(id: int) -> void:
	if not _actors.has(id):
		return

	var actor: Actor = _actors[id]
	_actors.erase(id)
	if is_instance_valid(actor):
		actor.queue_free()


func clear_all() -> void:
	for actor: Actor in _actors.values():
		if is_instance_valid(actor):
			actor.queue_free()

	_actors.clear()
	actor_id = -1


func has_actor(id: int) -> bool:
	return _actors.has(id) and is_instance_valid(_actors[id])


func read_all_actors() -> Array[Actor]:
	var valid_actors: Array[Actor] = []
	for actor: Actor in _actors.values():
		if is_instance_valid(actor):
			valid_actors.push_back(actor)
	return valid_actors


func read_actor_count() -> int:
	return read_all_actors().size()


func teleport_actor(actor_id: int, target_map: String, target_position: Vector2i, target_direction: Vector2i) -> void:
	var actor: Actor = read_actor(actor_id)
	if not actor:
		return

	# Aplicar direção ANTES de remover do mapa
	actor.write_direction(target_direction)

	# Remover actor do mapa antigo
	var old_parent: Node = actor.get_parent()
	if old_parent:
		old_parent.remove_child(actor)

	var new_map: Map = GameMaps.load_map(target_map)
	if not new_map:
		return

	actor.write_map_position(target_position)
	actor.write_visual_offset(Vector2.ZERO)

	var scene: Scene = GameScenes.read_current_scene()
	scene.add_child(new_map)

	# Adicionar actor no novo mapa
	new_map.add_child(actor)

	# Forçar animação idle com a nova direção
	actor._play_idle()
