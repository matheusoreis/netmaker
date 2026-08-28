extends RefCounted
class_name Map


## Identificador do mapa.
var id: int
## Nome identificador do mapa.
var identifier: String

## Nome do arquivo de música de fundo.
var bgm: String
## Nome do arquivo de som ambiente.
var bgs: String

## Dimensões do mapa em células.
var size: Vector2i

## Colisões do mapa indexadas por célula.
var collisions: Dictionary[Vector2i, int]
## Passagens do mapa indexadas por célula de origem.
var warps: Dictionary[Vector2i, Dictionary]

## Personagens presentes no mapa indexados por identificador.
var characters: Dictionary[int, Character]


## Cria um mapa com os dados informados.
func _init(id: int, identifier: String, bgm: String, bgs: String, size: Vector2i) -> void:
	self.id = id
	self.identifier = identifier

	self.bgm = bgm
	self.bgs = bgs

	self.size = size


## Importa as colisões do mapa.
func import_collisions(collisions: Dictionary) -> void:
	self.collisions.assign(collisions)


## Importa as passagens do mapa.
func import_warps(warps: Dictionary) -> void:
	self.warps.assign(warps)


## Retorna o tamanho do mapa em pixels.
func pixel_size() -> Vector2i:
	return Vector2i(size.x * Constants.CELL_SIZE, size.y * Constants.CELL_SIZE)


## Indica se uma posição está dentro dos limites do mapa.
func is_within_bounds(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < size.x and position.y >= 0 and position.y < size.y


## Converte uma célula do mapa para uma posição em pixels.
func to_screen(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * Constants.CELL_SIZE, cell.y * Constants.CELL_SIZE)


## Converte uma posição em pixels para uma célula do mapa.
func to_cell(position: Vector2) -> Vector2i:
	return Vector2i(int(position.x / Constants.CELL_SIZE), int(position.y / Constants.CELL_SIZE))


## Retorna as flags de colisão de uma célula.
func collision_flag(cell: Vector2i) -> int:
	return collisions.get(cell, Constants.CELL_NONE)


## Indica se uma célula está completamente bloqueada.
func is_solid(cell: Vector2i) -> bool:
	return (collision_flag(cell) & Constants.CELL_FULL_BLOCK) != 0


## Indica se existe uma passagem na célula informada.
func has_warp(cell: Vector2i) -> bool:
	return warps.has(cell)


## Retorna os dados da passagem na célula informada.
func get_warp(cell: Vector2i) -> Dictionary:
	return warps.get(cell, {})


## Indica se é possível mover-se na direção informada.
func can_pass(from: Vector2i, direction: Vector2i) -> bool:
	var to: Vector2i = from + direction

	if not is_within_bounds(from) or not is_within_bounds(to):
		return false

	var from_flag: int = collision_flag(from)
	var to_flag: int = collision_flag(to)

	if (from_flag & Constants.CELL_FULL_BLOCK) != 0:
		return false

	if (to_flag & Constants.CELL_FULL_BLOCK) != 0:
		return false

	var direction_flag: int = _direction_to_flag(direction)
	var opposite_flag: int = _direction_to_flag(-direction)

	if (from_flag & direction_flag) != 0:
		return false

	if (to_flag & opposite_flag) != 0:
		return false

	if abs(direction.x) == 1 and abs(direction.y) == 1:
		var horizontal_cell := Vector2i(from.x + direction.x, from.y)
		var vertical_cell := Vector2i(from.x, from.y + direction.y)

		if is_solid(horizontal_cell) or is_solid(vertical_cell):
			return false

	return true


## Adiciona um personagem ao mapa.
func add_character(character: Character) -> void:
	characters[character.id] = character


## Remove um personagem do mapa.
func remove_character(character_id: int) -> void:
	var character: Character = characters.get(character_id)
	if not character:
		return

	characters.erase(character_id)


## Retorna um personagem pelo seu identificador.
func get_character(character_id: int) -> Character:
	return characters.get(character_id)


## Retorna todos os personagens presentes no mapa.
func get_characters() -> Array[Character]:
	var result: Array[Character] = []
	result.assign(characters.values())
	return result


## Indica se existe um personagem na célula informada.
func has_character_at(cell: Vector2i) -> bool:
	for character: Character in characters.values():
		if character.get_cell() == cell:
			return true
	return false


## Retorna os personagens presentes na célula informada.
func get_characters_at(cell: Vector2i) -> Array[Character]:
	var result: Array[Character] = []
	for character: Character in characters.values():
		if character.get_cell() == cell:
			result.append(character)
	return result


## Retorna os dados do mapa em formato de array.
func to_array() -> Array:
	return [id, identifier, bgm, bgs, size, collisions, warps]


## Converte uma direção em sua flag de colisão correspondente.
func _direction_to_flag(direction: Vector2i) -> int:
	match direction:
		Vector2i.DOWN:
			return Constants.CELL_DOWN
		Vector2i.LEFT:
			return Constants.CELL_LEFT
		Vector2i.RIGHT:
			return Constants.CELL_RIGHT
		Vector2i.UP:
			return Constants.CELL_UP
		_:
			return Constants.CELL_NONE
