extends GridEntity2D
class_name Npc

var _map: GameMap
var _wait_timer: float = 0.0

const WAIT_MIN := 0.5
const WAIT_MAX := 8.0


func setup(map: GameMap, spawn_pos: Vector2i, npc_id: int) -> void:
	entity_id = npc_id
	_map = map

	_map.add_entity(self, spawn_pos)

	pathfinder.path_failed.connect(_on_path_failed)

	_wait_timer = 0.0

	_pick_new_destination()


func tick() -> void:
	if pathfinder == null:
		return

	if pathfinder.has_active_path(self):
		return

	if _wait_timer > 0:
		_wait_timer -= _map._delta
		return

	if not is_idle():
		return

	_pick_new_destination()


func _start_wait() -> void:
	_wait_timer = randf_range(WAIT_MIN, WAIT_MAX)


func _pick_new_destination() -> void:
	var target := _pick_random_tile()

	if target == map_position:
		_start_wait()
		return

	var path := pathfinder.find_path(map_position, target, self)

	if path.size() <= 1:
		_start_wait()
		return

	pathfinder.move_to_target(self, target)


func _on_path_failed(entity: GridEntity2D, _blocked: Vector2i) -> void:
	if entity != self:
		return

	_start_wait()


func _pick_random_tile() -> Vector2i:
	var bounds: Rect2i = _map.map_data.bounds
	var attempts := 10
	var min_distance := 2

	while attempts > 0:

		var x := randi_range(bounds.position.x, bounds.position.x + bounds.size.x - 1)
		var y := randi_range(bounds.position.y, bounds.position.y + bounds.size.y - 1)

		var tile := Vector2i(x, y)

		if tile == map_position:
			attempts -= 1
			continue

		if _map.is_cell_blocked(tile):
			attempts -= 1
			continue

		if (tile - map_position).length() < min_distance:
			attempts -= 1
			continue

		return tile

		attempts -= 1

	return map_position
