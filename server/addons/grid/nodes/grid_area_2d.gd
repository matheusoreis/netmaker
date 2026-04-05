## Área de consulta do grid. Calcula tiles e entidades ao redor de uma posição central.
##
## Adicione como filho de um [GridMap2D] para resolver [member world] automaticamente,
## ou atribua [member world] manualmente.
extends Node2D
class_name GridArea2D


enum Shape {
	RECTANGLE, ## Área retangular.
	ELLIPSE,   ## Área elíptica.
}


const CARDINAL_DIRS: Array[Vector2i] = [
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.DOWN,
]


@export_group("Area")

## Raio horizontal em tiles.
@export var radius_x: int = 3

## Raio vertical em tiles.
@export var radius_y: int = 3

## Forma da área.
@export var shape: Shape = Shape.RECTANGLE


@export_group("Filters")

## Se [code]true[/code], tiles bloqueados são incluídos nos resultados.
@export var ignore_blocked: bool = true

## Se [code]true[/code], tiles ocupados são incluídos nos resultados.
@export var ignore_occupied: bool = true


## Mundo de referência. Resolvido automaticamente se o pai for um [GridMap2D].
var world: GridMap2D = null


func _ready() -> void:
	if world == null and get_parent() is GridMap2D:
		world = get_parent()


## Retorna todos os tiles dentro da área ao redor de [param center].
func get_tiles(center: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for x: int in range(-radius_x, radius_x + 1):
		for y: int in range(-radius_y, radius_y + 1):
			if shape == Shape.ELLIPSE:
				var nx: float = float(x) / float(radius_x + 0.5)
				var ny: float = float(y) / float(radius_y + 0.5)
				if nx * nx + ny * ny > 1.0:
					continue

			var tile: Vector2i = center + Vector2i(x, y)

			if not world.is_within_bounds(tile):
				continue
			if not ignore_blocked and world.is_cell_blocked(tile):
				continue
			if not ignore_occupied and world.is_cell_occupied(tile):
				continue

			result.append(tile)

	return result


## Retorna [code]true[/code] se [param tile] está dentro da área ao redor de [param center].
func has_tile(center: Vector2i, tile: Vector2i) -> bool:
	return get_tiles(center).has(tile)


## Retorna todas as entidades presentes nos tiles da área ao redor de [param center].
## Use [param exclude] para ignorar uma entidade específica, como o dono da área.
func get_entities(center: Vector2i, exclude: GridEntity2D = null) -> Array[GridEntity2D]:
	var result: Array[GridEntity2D] = []

	for tile: Vector2i in get_tiles(center):
		var entity: GridEntity2D = world.get_entity_at(tile)
		if entity == null or entity == exclude:
			continue
		result.append(entity)

	return result


## Retorna [code]true[/code] se há alguma entidade na área ao redor de [param center].
## Use [param exclude] para ignorar uma entidade específica.
func has_entity(center: Vector2i, exclude: GridEntity2D = null) -> bool:
	for tile: Vector2i in get_tiles(center):
		var entity: GridEntity2D = world.get_entity_at(tile)
		if entity == null or entity == exclude:
			continue
		return true
	return false


## Retorna [code]true[/code] se há linha de visão direta entre [param from] e [param to].
## Usa o algoritmo de Bresenham. Tiles bloqueados interrompem a visão.
func has_line_of_sight(from: Vector2i, to: Vector2i) -> bool:
	var dx: int    = abs(to.x - from.x)
	var dy: int    = abs(to.y - from.y)
	var step_x: int = 1 if from.x < to.x else -1
	var step_y: int = 1 if from.y < to.y else -1
	var x: int     = from.x
	var y: int     = from.y
	var err: int   = dx - dy

	while true:
		var current: Vector2i = Vector2i(x, y)
		if current != from and current != to:
			if world.is_cell_blocked(current):
				return false
		if x == to.x and y == to.y:
			break
		var e2: int = 2 * err
		if e2 > -dy:
			err -= dy
			x   += step_x
		if e2 < dx:
			err += dx
			y   += step_y

	return true


## Preenche a partir de [param origin] por flood fill, respeitando os filtros da área.
## [param max_tiles] limita o número de tiles retornados.
func flood_fill(origin: Vector2i, max_tiles: int) -> Array[Vector2i]:
	var visited: Dictionary[Vector2i, bool] = {}
	var result: Array[Vector2i] = []
	var queue: GridBoundedQueue = GridBoundedQueue.new(max_tiles)

	visited[origin] = true
	queue.enqueue(origin)

	while not queue.is_empty() and result.size() < max_tiles:
		var current: Vector2i = queue.dequeue()
		result.append(current)

		for dir: Vector2i in CARDINAL_DIRS:
			var neighbor: Vector2i = current + dir

			if visited.has(neighbor):
				continue
			if not world.is_within_bounds(neighbor):
				continue
			if not ignore_blocked and world.is_cell_blocked(neighbor):
				continue
			if not ignore_occupied and world.is_cell_occupied(neighbor):
				continue

			visited[neighbor] = true
			queue.enqueue(neighbor)

	return result
