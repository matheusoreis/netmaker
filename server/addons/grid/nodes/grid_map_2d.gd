## Nó central do sistema de grid. Gerencia tiles, entidades e movimento.
##
## Inicialize o mapa via [method setup] ou [method setup_from_dict] e registre entidades
## com [method add_entity]. Toda lógica de pathfinding e detecção fica nos nós filhos.
extends Node2D
class_name GridMap2D


## Resultado de uma requisição de movimento. Retornado por [method request_move].
class MoveResult:
	var entity: GridEntity2D = null         ## Entidade que solicitou o movimento.
	var from: Vector2i = Vector2i.ZERO      ## Posição de origem em coordenadas de grid.
	var to: Vector2i = Vector2i.ZERO        ## Posição de destino em coordenadas de grid.
	var direction: Vector2i = Vector2i.ZERO ## Direção do movimento.
	var success: bool = false               ## [code]true[/code] se o movimento foi aprovado.
	var rejection_reason: String = ""       ## Motivo da rejeição, ou vazio se bem-sucedido.
	var world_position: Vector2 = Vector2.ZERO ## Posição de destino em coordenadas de mundo.


## Emitido quando uma entidade é adicionada ao mundo.
signal entity_added(entity: GridEntity2D)

## Emitido quando uma entidade é removida do mundo.
signal entity_removed(entity: GridEntity2D)

## Emitido quando uma entidade conclui um passo de movimento.
signal entity_moved(entity: GridEntity2D, from: Vector2i, to: Vector2i)

## Emitido quando uma requisição de movimento é rejeitada.
signal move_rejected(entity: GridEntity2D, target: Vector2i, reason: String)

## Emitido ao concluir a configuração do mundo via [method setup].
signal world_ready()


## Identificador único deste mundo.
@export var identifier: String = ""

## Tamanho de cada tile em pixels.
@export var tile_size: int = 32


## Região do mundo em coordenadas de grid.
var bounds: Rect2i = Rect2i()


var _tiles: Array[int] = []
var _occupied: Array = []
var _registry: Dictionary[GridEntity2D, Vector2i] = {}


## Configura o mundo a partir de um [GridMapResource].
## Emite [signal world_ready] ao concluir.
func setup(resource: GridMapResource) -> void:
	identifier = resource.identifier
	tile_size  = resource.tile_size
	bounds     = Rect2i(resource.bounds_x, resource.bounds_y, resource.bounds_w, resource.bounds_h)
	_tiles.assign(resource.tiles)
	_build_occupied_grid()
	world_ready.emit()


## Retorna [code]true[/code] se [param grid_pos] está dentro dos limites do mundo.
func is_within_bounds(grid_pos: Vector2i) -> bool:
	var local: Vector2i = _to_local(grid_pos)
	return _in_bounds(local.x, local.y)


## Retorna o [GridTileData] do tile em [param grid_pos].
## Tiles fora dos limites retornam um tile com [member GridTileData.blocked] igual a [code]true[/code].
func get_tile_data(grid_pos: Vector2i) -> GridTileData:
	return _read_tile(grid_pos)


## Retorna [code]true[/code] se o tile em [param grid_pos] está bloqueado.
## Tiles fora dos limites sempre retornam [code]true[/code].
func is_cell_blocked(grid_pos: Vector2i) -> bool:
	if not is_within_bounds(grid_pos):
		return true
	return _read_tile(grid_pos).blocked


## Retorna [code]true[/code] se o tile em [param grid_pos] está ocupado por uma entidade.
func is_cell_occupied(grid_pos: Vector2i) -> bool:
	var local: Vector2i = _to_local(grid_pos)
	if not _in_bounds(local.x, local.y):
		return false
	return _occupied[local.x][local.y] != null


## Retorna a entidade em [param grid_pos], ou [code]null[/code] se o tile estiver vazio.
func get_entity_at(grid_pos: Vector2i) -> GridEntity2D:
	var local: Vector2i = _to_local(grid_pos)
	if not _in_bounds(local.x, local.y):
		return null
	return _occupied[local.x][local.y] as GridEntity2D


## Retorna [code]true[/code] se mover de [param grid_pos] na [param direction] está bloqueado.
## Verifica o tile de origem e a entrada inversa do tile vizinho.
func is_direction_blocked(grid_pos: Vector2i, direction: Vector2i) -> bool:
	if not is_within_bounds(grid_pos):
		return true
	if _read_tile(grid_pos).blocks_direction(direction):
		return true
	var neighbor: Vector2i = grid_pos + direction
	if is_within_bounds(neighbor) and _read_tile(neighbor).blocks_direction(-direction):
		return true
	return false


## Converte uma posição de mundo para coordenadas de grid.
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / tile_size), int(world_pos.y / tile_size))


## Converte [param grid_pos] para a posição de mundo do canto superior esquerdo do tile.
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * tile_size, grid_pos.y * tile_size)


## Converte [param grid_pos] para a posição de mundo do centro do tile.
func grid_to_world_center(grid_pos: Vector2i) -> Vector2:
	return grid_to_world(grid_pos) + Vector2(tile_size * 0.5, tile_size * 0.5)


## Valida se [param mover] pode se mover de [param from] na [param direction].
## Retorna uma string vazia se válido, ou o motivo da rejeição:
## [code]"out_of_bounds"[/code], [code]"tile_blocked"[/code],
## [code]"direction_blocked"[/code], [code]"entity_blocked"[/code].
func check_move(from: Vector2i, direction: Vector2i, mover: GridEntity2D = null) -> String:
	var to: Vector2i = from + direction

	if not is_within_bounds(to):
		return "out_of_bounds"
	if is_cell_blocked(to):
		return "tile_blocked"
	if is_direction_blocked(from, direction):
		return "direction_blocked"

	var occupant: GridEntity2D = get_entity_at(to)
	if occupant != null and occupant != mover:
		if mover == null or occupant.blocks_entity(mover):
			return "entity_blocked"

	return ""


## Processa uma requisição de movimento de [param entity] na [param direction].
## Atualiza a posição lógica imediatamente se aprovado. Emite [signal move_rejected] em falha.
func request_move(entity: GridEntity2D, direction: Vector2i) -> MoveResult:
	var result: MoveResult = MoveResult.new()
	result.entity    = entity
	result.from      = entity.map_position
	result.to        = entity.map_position + direction
	result.direction = direction

	var reason: String = check_move(entity.map_position, direction, entity)
	if reason != "":
		result.rejection_reason = reason
		move_rejected.emit(entity, result.to, reason)
		return result

	_set_occupant(result.from, null)
	_set_occupant(result.to, entity)

	entity.map_position   = result.to
	result.success        = true
	result.world_position = grid_to_world(result.to)

	return result


## Deve ser chamado pela entidade ao concluir a animação de movimento. Emite [signal entity_moved].
func notify_move_finished(entity: GridEntity2D, from: Vector2i, to: Vector2i) -> void:
	entity_moved.emit(entity, from, to)


## Registra [param entity] no mundo na posição [param grid_pos]. Emite [signal entity_added].
func add_entity(entity: GridEntity2D, grid_pos: Vector2i) -> void:
	if not is_within_bounds(grid_pos):
		push_error("GridMap2D [%s]: posição fora dos limites: %s." % [identifier, grid_pos])
		return

	_set_occupant(grid_pos, entity)

	entity.map_position  = grid_pos
	entity.current_world = self
	entity.position      = grid_to_world(grid_pos)
	entity._on_added_to_world()
	entity_added.emit(entity)


## Teleporta [param entity] para [param grid_pos] sem animação. Emite [signal entity_moved].
func teleport_entity(entity: GridEntity2D, grid_pos: Vector2i) -> void:
	if not _registry.has(entity):
		push_warning("GridMap2D [%s]: teleport_entity chamado para entidade não registrada." % identifier)
		return
	if not is_within_bounds(grid_pos):
		push_error("GridMap2D [%s]: posição fora dos limites: %s." % [identifier, grid_pos])
		return

	var from: Vector2i = _registry[entity]

	_set_occupant(from, null)
	_set_occupant(grid_pos, entity)

	entity.map_position = grid_pos
	entity.position     = grid_to_world(grid_pos)
	entity_moved.emit(entity, from, grid_pos)


## Remove [param entity] do mundo sem destruí-la. Emite [signal entity_removed].
func remove_entity(entity: GridEntity2D) -> void:
	if not _registry.has(entity):
		push_warning("GridMap2D [%s]: entidade desconhecida." % identifier)
		return

	_set_occupant(_registry[entity], null)
	entity.current_world = null
	entity_removed.emit(entity)


## Retorna a entidade cujo [member GridEntity2D.id] corresponde a [param id], ou [code]null[/code].
func get_entity_by_id(id: int) -> GridEntity2D:
	for entity: GridEntity2D in _registry:
		if entity.id == id:
			return entity
	return null


## Retorna todas as entidades registradas no mundo.
func get_all_entities() -> Array[GridEntity2D]:
	var result: Array[GridEntity2D] = []
	result.assign(_registry.keys())
	return result


func _build_occupied_grid() -> void:
	var w: int = bounds.size.x
	var h: int = bounds.size.y
	_occupied.resize(w)
	for x: int in w:
		_occupied[x] = []
		_occupied[x].resize(h)
		for y: int in h:
			_occupied[x][y] = null


func _set_occupant(grid_pos: Vector2i, entity: GridEntity2D) -> void:
	var local: Vector2i = _to_local(grid_pos)
	if _in_bounds(local.x, local.y):
		_occupied[local.x][local.y] = entity

	if entity != null:
		_registry[entity] = grid_pos
	else:
		for e: GridEntity2D in _registry:
			if _registry[e] == grid_pos:
				_registry.erase(e)
				break


func _read_tile(grid_pos: Vector2i) -> GridTileData:
	var tile: GridTileData = GridTileData.new()
	var local: Vector2i   = _to_local(grid_pos)
	var idx: int          = local.x * bounds.size.y + local.y

	if idx >= 0 and idx < _tiles.size():
		var raw: int = _tiles[idx]
		tile.blocked = (raw & 0x01) != 0
		if (raw & 0x02) != 0: tile.blocked_directions.append(Vector2i(-1,  0))
		if (raw & 0x04) != 0: tile.blocked_directions.append(Vector2i( 1,  0))
		if (raw & 0x08) != 0: tile.blocked_directions.append(Vector2i( 0, -1))
		if (raw & 0x10) != 0: tile.blocked_directions.append(Vector2i( 0,  1))

	return tile


func _to_local(grid_pos: Vector2i) -> Vector2i:
	return grid_pos - bounds.position


func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < bounds.size.x and y >= 0 and y < bounds.size.y
