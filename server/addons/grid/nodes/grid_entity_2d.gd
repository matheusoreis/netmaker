## Entidade que ocupa e se move sobre um [GridMap2D].
##
## Gerencia a posição lógica no grid e a fila de movimentos.
## Registre a entidade no mundo via [method GridMap2D.add_entity].
## Estenda esta classe e sobrescreva [method _on_added_to_world] e
## [method _on_move_finished] para implementar comportamento customizado.
extends Node2D
class_name GridEntity2D


## Emitido quando um passo de movimento começa.
signal move_started(from: Vector2i, to: Vector2i)

## Emitido quando um passo de movimento é concluído.
signal move_finished(grid_pos: Vector2i)

## Emitido quando um movimento é bloqueado.
signal move_blocked(target: Vector2i, reason: String)

## Emitido quando a direção de face muda.
signal facing_changed(new_direction: Vector2i)

## Emitido quando a fila de movimentos é esvaziada.
signal move_queue_cleared()


@export_group("Grid")

## Identificador numérico desta entidade. Usado por [method GridMap2D.get_entity_by_id].
@export var id: int = 0

## Posição atual em coordenadas de grid.
@export var map_position: Vector2i = Vector2i.ZERO

## Se [code]false[/code], a entidade ignora todas as requisições de movimento.
@export var can_move: bool = true


@export_group("Movement")

## Duração em segundos de cada passo de movimento.
@export var move_duration: float = 0.25

## Capacidade máxima da fila de movimentos. Alterar em runtime descarta a fila atual.
@export var move_queue_capacity: int = 256:
	set(value):
		move_queue_capacity = value
		_move_queue = GridBoundedQueue.new(move_queue_capacity)

## Se [code]true[/code], sobrescreve o movimento mais antigo quando a fila está cheia.
@export var move_queue_overwrite: bool = false


@export_group("Collision")

## Camadas de colisão desta entidade.
@export_flags("Player", "Enemy", "Obstacle", "Interactable") var collision_layer: int = 1

## Máscaras de colisão que esta entidade respeita.
@export_flags("Player", "Enemy", "Obstacle", "Interactable") var collision_mask: int = 1


## Mundo ao qual esta entidade pertence. Atribuído por [method GridMap2D.add_entity].
var current_world: GridMap2D = null

## Direção para a qual a entidade está voltada.
var facing: Vector2i = Vector2i(0, 1)

## [code]true[/code] enquanto o movimento lógico está em progresso.
var is_moving: bool = false


var _move_origin: Vector2i = Vector2i.ZERO
var _move_queue: GridBoundedQueue = GridBoundedQueue.new(1)
var _move_timer: float = 0.0


func _ready() -> void:
	_move_queue = GridBoundedQueue.new(move_queue_capacity)


func _process(delta: float) -> void:
	if not is_moving:
		return

	_move_timer -= delta
	if _move_timer > 0.0:
		return

	is_moving = false

	if current_world:
		current_world.notify_move_finished(self, _move_origin, map_position)

	_flush_queue()

	move_finished.emit(map_position)
	_on_move_finished(map_position)



## Enfileira um movimento na [param direction].
## Retorna [code]false[/code] se a fila estiver cheia e [member move_queue_overwrite] for [code]false[/code].
func enqueue_move(direction: Vector2i) -> bool:
	if _move_queue.is_full():
		if move_queue_overwrite:
			_move_queue.dequeue()
		else:
			return false

	_move_queue.enqueue(direction)

	if not is_moving:
		_flush_queue()

	return true


## Esvazia a fila de movimentos. Emite [signal move_queue_cleared].
func clear_move_queue() -> void:
	_move_queue.clear()
	move_queue_cleared.emit()


## Enfileira as direções de um caminho pré-calculado, substituindo a fila atual.
## Direções que excedam a capacidade são descartadas silenciosamente.
func follow_path(path: Array[Vector2i]) -> void:
	if path.is_empty():
		return
	clear_move_queue()

	var cursor: Vector2i = map_position
	for tile: Vector2i in path:
		var dir: Vector2i = tile - cursor
		if _move_queue.is_full():
			if move_queue_overwrite:
				_move_queue.dequeue()
			else:
				cursor = tile
				continue
		_move_queue.enqueue(dir)
		cursor = tile

	if not is_moving:
		_flush_queue()


## Teleporta a entidade para [param grid_pos], cancelando movimento e fila atuais.
func teleport_to(grid_pos: Vector2i) -> void:
	if not current_world:
		push_warning("GridEntity2D [%d]: teleport_to chamado sem current_world." % id)
		return
	clear_move_queue()
	is_moving = false
	current_world.teleport_entity(self, grid_pos)


## Retorna [code]true[/code] se esta entidade bloqueia o movimento de [param other],
## com base nas camadas e máscaras de colisão.
func blocks_entity(other: GridEntity2D) -> bool:
	return (collision_layer & other.collision_mask) != 0


## Retorna [code]true[/code] se a entidade não está se movendo e a fila está vazia.
func is_idle() -> bool:
	return not is_moving and _move_queue.is_empty()


## Retorna o número de movimentos pendentes na fila.
func get_queue_size() -> int:
	return _move_queue.size()


## Chamado por [method GridMap2D.add_entity] ao registrar esta entidade no mundo.
## Sobrescreva para inicializar referências ou estado dependente do mundo.
func _on_added_to_world() -> void:
	pass


## Chamado ao concluir cada passo de movimento.
## Sobrescreva para reagir ao fim de um movimento, como checar eventos no tile.
func _on_move_finished(_grid_pos: Vector2i) -> void:
	pass


func _flush_queue() -> void:
	if _move_queue.is_empty():
		return
	_attempt_move(_move_queue.dequeue())


func _attempt_move(direction: Vector2i) -> void:
	if not current_world or not can_move or is_moving:
		return

	if direction != facing:
		facing = direction
		facing_changed.emit(facing)

	var result: GridMap2D.MoveResult = current_world.request_move(self, direction)

	if not result.success:
		move_blocked.emit(result.to, result.rejection_reason)
		clear_move_queue()
		return

	_move_origin = result.from

	var is_diagonal: bool = direction.x != 0 and direction.y != 0
	_move_timer = move_duration * (1.414 if is_diagonal else 1.0)
	is_moving   = true

	move_started.emit(result.from, result.to)
