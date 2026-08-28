extends Scene
class_name Game


## Mapa atual do jogo.
var current_map: Map
## Personagem atual controlado pelo jogador.
var current_character: Character

## Indica se o chat está ativo.
var chat_active: bool = false


## Solicita os dados do mapa ao servidor.
func _ready() -> void:
	Network.exec(&"map_data")


## Processa as entradas do jogador a cada quadro.
func _physics_process(_delta: float) -> void:
	_handle_input()


## Gerencia todas as entradas do jogador.
func _handle_input() -> void:
	if not _can_process_input():
		return

	if _handle_admin_toggle():
		return

	var direction: Vector2i = _get_movement_direction()
	if direction == Vector2i.ZERO:
		return

	_execute_movement(direction)


## Verifica se o jogador pode processar entradas.
func _can_process_input() -> bool:
	if current_map == null or current_character == null:
		return false

	if current_character.is_transitioning():
		return false

	if current_character.is_warping():
		return false

	if chat_active:
		return false

	return true


## Verifica e processa o toggle do administrador.
func _handle_admin_toggle() -> bool:
	if Input.is_action_just_pressed("admin"):
		toggle_interface(&"Admin")
		return true
	return false


## Obtém a direção do movimento baseada nas teclas pressionadas.
func _get_movement_direction() -> Vector2i:
	if Input.is_action_pressed("move_up"):
		return Vector2i.UP
	elif Input.is_action_pressed("move_down"):
		return Vector2i.DOWN
	elif Input.is_action_pressed("move_left"):
		return Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		return Vector2i.RIGHT

	return Vector2i.ZERO


## Executa o movimento do personagem na direção informada.
func _execute_movement(direction: Vector2i) -> void:
	if not current_map.can_pass(current_character.cell, direction):
		return

	current_character.move(direction)
	Network.exec(&"move_character", [direction])
