extends Scene
class_name Menu


var current_map: Map
var current_character: Character


func _ready() -> void:
	var character_scene: PackedScene = load("res://source/gameplay/map/entity/character.tscn")
	if character_scene == null:
		return

	current_character = character_scene.instantiate() as Character
	if current_character == null:
		return

	current_character.setup(
		1,
		"Teste",
		"fighter01",
		0,
		Vector2i(0, 0),
		Vector2i.DOWN
	)

	add_child(current_character)


func _physics_process(_delta: float) -> void:
	_handle_movement()


func _handle_movement() -> void:
	if current_character == null:
		return

	if current_character.is_transitioning():
		return

	var direction: Vector2i = Vector2i.ZERO
	if Input.is_action_pressed("ui_up"):
		direction = Vector2i.UP
	elif Input.is_action_pressed("ui_down"):
		direction = Vector2i.DOWN
	elif Input.is_action_pressed("ui_left"):
		direction = Vector2i.LEFT
	elif Input.is_action_pressed("ui_right"):
		direction = Vector2i.RIGHT

	if direction != Vector2i.ZERO:
		current_character.move(direction)
