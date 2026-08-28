extends RefCounted
class_name Entity


## Identificador da entidade.
var id: int
## Nome identificador da entidade.
var identifier: String

## Nome do spritesheet da entidade.
var spritesheet: String

## Identificador do mapa atual.
var map: int
## Posição atual da entidade no mapa.
var cell: Vector2i
## Direção para a qual a entidade está virada.
var facing: Vector2i


## Cria uma entidade com os dados informados.
func _init(id: int, identifier: String, spritesheet: String, map: int, cell: Vector2i, facing: Vector2i) -> void:
	self.id = id
	self.identifier = identifier

	self.spritesheet = spritesheet

	self.map = map
	self.cell = cell
	self.facing = facing


## Retorna os dados da entidade em formato de array.
func to_array() -> Array:
	return [
		self.id,
		self.identifier,
		self.spritesheet,
		self.map,
		self.cell,
		self.facing
	]
