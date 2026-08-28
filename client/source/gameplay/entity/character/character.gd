extends Entity
class_name Character


## Fila de movimentos pendentes do personagem.
var _queue: Queue
## Componente responsável pela animação do personagem.
var _animator: CharacterAnimator

## Deslocamento do personagem durante o movimento.
var _movement_offset: Vector2 = Vector2.ZERO
## Indica se o personagem está transitando entre células.
var _is_transitioning: bool = false

## Tempo restante de espera após uma passagem entre mapas.
var _warp_cooldown: float = 0.0


## Inicializa o personagem com seus dados e componentes.
func setup(
	id: int,
	identifier: String,
	spritesheet: String,
	map: int,
	cell: Vector2i,
	facing: Vector2i
) -> void:
	super.setup(id, identifier, spritesheet, map, cell, facing)

	_queue = Queue.new(Constants.MAX_PENDING_MOVES)
	_animator = CharacterAnimator.new(%Sprite2D)

	_load_texture()
	_calculate_sprite_offset()

	position = _cell_to_center(cell)
	_animator.sync(facing)


## Processa o movimento e a animação do personagem a cada quadro.
func _physics_process(delta: float) -> void:
	_update_movement(delta)
	_position_sync()
	_update_warp_cooldown(delta)


## Indica se o personagem está em transição entre células.
func is_transitioning() -> bool:
	return _is_transitioning


## Indica se o personagem está em cooldown de passagem.
func is_warping() -> bool:
	return _warp_cooldown > 0.0


## Inicia o cooldown de passagem e limpa a fila de movimentos.
func start_warp_cooldown() -> void:
	_warp_cooldown = Constants.WARP_COOLDOWN
	_queue.clear()


## Atualiza o contador de cooldown de passagem.
func _update_warp_cooldown(delta: float) -> void:
	if _warp_cooldown > 0.0:
		_warp_cooldown = max(_warp_cooldown - delta, 0.0)


## Move o personagem na direção informada.
func move(direction: Vector2i) -> void:
	if _queue.enqueue(direction):
		return
	_queue.dequeue()
	_queue.enqueue(direction)


## Corrige a posição e a direção do personagem para o servidor.
func correct(new_cell: Vector2i, new_facing: Vector2i) -> void:
	_queue.clear()
	cell = new_cell
	facing = new_facing
	_movement_offset = Vector2.ZERO
	_is_transitioning = false
	_position_sync()
	_animator.sync(facing)


## Inicia o movimento na direção informada.
func _start_move(direction: Vector2i) -> void:
	facing = direction
	_movement_offset = Vector2(-direction) * Constants.CELL_SIZE
	cell += direction
	_is_transitioning = true
	_animator.on_move_started()
	_animator.sync(facing)


## Carrega a textura do personagem a partir do spritesheet.
func _load_texture() -> void:
	var path: String = Constants.CHARACTER_SPRITE_DIRECTORY + spritesheet + ".png"
	if not ResourceLoader.exists(path):
		return

	%Sprite2D.texture = load(path)


## Converte uma célula para a posição central em pixels.
func _cell_to_center(cell: Vector2i) -> Vector2:
	return Vector2(
		cell.x * Constants.CELL_SIZE + Constants.CELL_SIZE / 2.0,
		cell.y * Constants.CELL_SIZE + Constants.CELL_SIZE
	)


## Calcula o deslocamento do sprite baseado no tamanho do frame.
func _calculate_sprite_offset() -> void:
	var texture: Texture2D = %Sprite2D.texture
	if texture == null:
		return

	var frame_size: Vector2 = texture.get_size() / Vector2(Constants.SPRITESHEET_COLUMNS, Constants.SPRITESHEET_ROWS)
	%Sprite2D.offset = Vector2(0, -frame_size.y / 2.0)


## Sincroniza a posição visual do personagem com seu estado interno.
func _position_sync() -> void:
	position = _cell_to_center(cell) + _movement_offset


## Processa o movimento do personagem enquanto transitando.
func _update_movement(delta: float) -> void:
	if _is_transitioning:
		_process_transition(delta)
		return

	if _queue.is_empty():
		return

	_start_move(_queue.dequeue())


## Anima a transição do personagem entre células.
func _process_transition(delta: float) -> void:
	var speed: float = Constants.WALKING_SPEED * Constants.CELL_SIZE * delta
	_movement_offset = _movement_offset.move_toward(Vector2.ZERO, speed)

	_position_sync()

	_animator.on_move_progress(_movement_offset)
	_animator.sync(facing)

	if _movement_offset.is_zero_approx():
		_finish_transition()


## Finaliza a transição e sincroniza a animação.
func _finish_transition() -> void:
	_is_transitioning = false
	_position_sync()
	_animator.on_move_finished()
	_animator.sync(facing)
