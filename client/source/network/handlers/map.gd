extends Node
class_name MapHandler


## Registra as funções remotas relacionadas a mapas.
func register() -> Error:
	return Network.register([
		map_data,
		character_data,
		character_to_characters,
		move_character,
		correct_movement,
		character_left,
		warp_map
	])


## Desregistra as funções remotas relacionadas a mapas.
func unregister() -> Error:
	return Network.unregister([
		map_data,
		character_data,
		character_to_characters,
		move_character,
		correct_movement,
		character_left,
		warp_map
	])


## Recebe os dados completos do mapa e o instancia.
func map_data(id: int, identifier: String, bgm: String, bgs: String, size: Vector2i, collisions: Dictionary, warps: Dictionary, characters: Array) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var game: Game = main.current_scene
	if game == null:
		return

	_unload_current_map(game)

	var map_path: String = Constants.MAPS_DATA_DIRECTORY + "%d.tscn" % id
	var character_path: String = "res://source/gameplay/entity/character/character.tscn"

	if not ResourceLoader.exists(map_path):
		push_error("Mapa não encontrado: ", map_path)
		return

	var packed_map: PackedScene = load(map_path)
	if not packed_map:
		push_error("Falha ao carregar cena do mapa: ", map_path)
		return

	var map_instance: Map = packed_map.instantiate()
	if not map_instance:
		push_error("Falha ao instanciar mapa: ", map_path)
		return

	map_instance.setup(id, identifier, bgm, bgs, size)

	map_instance.import_collisions(collisions)
	map_instance.import_warps(warps)

	var packed_character: PackedScene = load(character_path)
	if not packed_character:
		push_error("Falha ao carregar cena do personagem: ", character_path)
		return

	for character_data in characters:
		var character: Character = packed_character.instantiate()
		if character == null:
			continue

		character.setup(
			character_data[0],
			character_data[1],
			character_data[2],
			character_data[3],
			character_data[4],
			character_data[5]
		)

		map_instance.add_character(character)

	game.current_map = map_instance
	game.add_child(map_instance)

	Network.exec(&"enter_map")


## Recebe os dados do personagem do jogador e o instancia.
func character_data(character_data: Array) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var game: Game = main.current_scene
	if game == null:
		return

	var map: Map = game.current_map
	if map == null:
		return

	var character_path: String = "res://source/gameplay/entity/character/character.tscn"

	if not ResourceLoader.exists(character_path):
		push_error("Cena do personagem não encontrada: ", character_path)
		return

	var packed_character: PackedScene = load(character_path)
	if not packed_character:
		push_error("Falha ao carregar cena do personagem: ", character_path)
		return

	var character: Character = packed_character.instantiate()
	if character == null:
		push_error("Falha ao instanciar personagem")
		return

	character.setup(
		character_data[0],
		character_data[1],
		character_data[2],
		character_data[3],
		character_data[4],
		character_data[5]
	)

	var map_pixel_size: Vector2i = map.pixel_size()

	var camera: Camera2D = Camera2D.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_pixel_size.x
	camera.limit_bottom = map_pixel_size.y
	camera.zoom = Vector2i(2, 2)

	character.add_child(camera)

	game.current_map.add_character(character)
	game.current_character = character

	character.start_warp_cooldown()


## Recebe dados de outros personagens e os instancia no mapa.
func character_to_characters(character_data: Array) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var game: Game = main.current_scene
	if game == null:
		return

	var character_path: String = "res://source/gameplay/entity/character/character.tscn"

	if not ResourceLoader.exists(character_path):
		push_error("Cena do personagem não encontrada: ", character_path)
		return

	var packed_character: PackedScene = load(character_path)
	if not packed_character:
		push_error("Falha ao carregar cena do personagem: ", character_path)
		return

	var character: Character = packed_character.instantiate()
	if character == null:
		push_error("Falha ao instanciar personagem")
		return

	character.setup(
		character_data[0],
		character_data[1],
		character_data[2],
		character_data[3],
		character_data[4],
		character_data[5]
	)

	game.current_map.add_character(character)


## Move um personagem na direção informada.
func move_character(id: int, direction: Vector2i) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var game: Game = main.current_scene
	if game == null:
		return

	var character: Character = game.current_map.get_character(id)
	if character == null:
		return

	character.move(direction)


## Corrige a posição e direção do personagem do jogador.
func correct_movement(cell: Vector2i, facing: Vector2i) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var game: Game = main.current_scene
	if game == null:
		return

	game.current_character.correct(cell, facing)


## Remove um personagem que saiu do mapa.
func character_left(id: int) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var game: Game = main.current_scene
	if game == null:
		return

	game.current_map.remove_character(id)


## Troca para um novo mapa.
func warp_map(_map_id: int) -> void:
	var main: Main = get_tree().root.get_node("./Main")
	if main == null:
		return

	var game: Game = main.current_scene
	if game == null:
		return

	_unload_current_map(game)


## Descarrega o mapa atual e libera seus recursos.
func _unload_current_map(game: Game) -> void:
	if game.current_map == null:
		return

	var old_map: Map = game.current_map

	game.current_map = null
	game.current_character = null

	if old_map.get_parent():
		old_map.get_parent().remove_child(old_map)

	old_map.free()
