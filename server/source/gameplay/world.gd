extends RefCounted
class_name GameMap


## Resultado de uma requisição de movimento.
class MoveResult:
	var entity_id: int = 0
	var from: Vector2i = Vector2i.ZERO
	var to: Vector2i = Vector2i.ZERO
	var direction: Vector2i = Vector2i.ZERO
	var success: bool = false
	var rejection_reason: String = ""


var map_id: int = -1

var _bounds: Rect2i = Rect2i()
var _tiles: Array[int] = []

## entity_id → posição em grid
var _entities: Dictionary[int, Vector2i] = {}


func _init(p_map_id: int, resource: GridMapResource) -> void:
	map_id  = p_map_id
	_bounds = Rect2i(resource.bounds_x, resource.bounds_y, resource.bounds_w, resource.bounds_h)
	_tiles.assign(resource.tiles)


# ------------------------------------------------------------------ entidades

## Registra [param entity_id] na posição [param pos].
## Retorna [code]false[/code] se a posição for inválida.
func join(entity_id: int, pos: Vector2i) -> bool:
	if not _in_bounds(pos):
		push_error("GameMap [%d]: posição fora dos limites: %s." % [map_id, pos])
		return false

	_entities[entity_id] = pos
	return true


## Remove [param entity_id] do mapa.
func leave(entity_id: int) -> void:
	_entities.erase(entity_id)


## Retorna [code]true[/code] se o mapa não tem nenhuma entidade.
func is_empty() -> bool:
	return _entities.is_empty()


## Retorna a posição de [param entity_id], ou [code]Vector2i(-1, -1)[/code] se não estiver no mapa.
func get_position(entity_id: int) -> Vector2i:
	return _entities.get(entity_id, Vector2i(-1, -1))


## Retorna [code]true[/code] se [param entity_id] está neste mapa.
func has_entity(entity_id: int) -> bool:
	return _entities.has(entity_id)


## Retorna todos os entity_ids registrados.
func get_all_entities() -> Array[int]:
	var result: Array[int] = []
	result.assign(_entities.keys())
	return result


## Retorna o entity_id na posição [param pos], ou [code]-1[/code] se vazia.
func get_entity_at(pos: Vector2i) -> int:
	for id: int in _entities:
		if _entities[id] == pos:
			return id
	return -1


# ------------------------------------------------------------------ movimento

## Processa uma requisição de movimento de [param entity_id] na [param direction].
## Atualiza a posição lógica imediatamente se aprovado.
func request_move(entity_id: int, direction: Vector2i) -> MoveResult:
	var result: MoveResult = MoveResult.new()
	result.entity_id = entity_id
	result.direction = direction

	if not _entities.has(entity_id):
		result.rejection_reason = "entity_not_found"
		return result

	result.from = _entities[entity_id]
	result.to   = result.from + direction

	var reason: String = _check_move(result.from, result.to, entity_id)
	if reason != "":
		result.rejection_reason = reason
		return result

	_entities[entity_id] = result.to
	result.success = true
	return result


# ------------------------------------------------------------------ tiles

## Retorna [code]true[/code] se [param pos] está dentro dos limites do mapa.
func is_within_bounds(pos: Vector2i) -> bool:
	return _in_bounds(pos)


## Retorna [code]true[/code] se o tile em [param pos] está bloqueado.
func is_cell_blocked(pos: Vector2i) -> bool:
	if not _in_bounds(pos):
		return true
	return (_read_tile(pos) & 0x01) != 0


# ------------------------------------------------------------------ privado

func _check_move(from: Vector2i, to: Vector2i, entity_id: int) -> String:
	if not _in_bounds(to):
		return "out_of_bounds"
	if is_cell_blocked(to):
		return "tile_blocked"
	if _is_direction_blocked(from, to - from):
		return "direction_blocked"

	var occupant: int = get_entity_at(to)
	if occupant != -1 and occupant != entity_id:
		return "entity_blocked"

	return ""


func _is_direction_blocked(from: Vector2i, direction: Vector2i) -> bool:
	if _tile_blocks_direction(from, direction):
		return true
	var neighbor: Vector2i = from + direction
	if _in_bounds(neighbor) and _tile_blocks_direction(neighbor, -direction):
		return true
	return false


func _tile_blocks_direction(pos: Vector2i, direction: Vector2i) -> bool:
	var raw: int = _read_tile(pos)
	match direction:
		Vector2i(-1,  0): return (raw & 0x02) != 0
		Vector2i( 1,  0): return (raw & 0x04) != 0
		Vector2i( 0, -1): return (raw & 0x08) != 0
		Vector2i( 0,  1): return (raw & 0x10) != 0
	return false


func _read_tile(pos: Vector2i) -> int:
	var local: Vector2i = pos - _bounds.position
	var idx: int = local.x * _bounds.size.y + local.y
	if idx < 0 or idx >= _tiles.size():
		return 0x01
	return _tiles[idx]


func _in_bounds(pos: Vector2i) -> bool:
	var local: Vector2i = pos - _bounds.position
	return local.x >= 0 and local.x < _bounds.size.x \
		and local.y >= 0 and local.y < _bounds.size.y
