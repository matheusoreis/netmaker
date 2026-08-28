extends Node2D
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


## Inicializa os dados da entidade.
func setup(id: int, identifier: String, spritesheet: String, map: int, cell: Vector2i, facing: Vector2i) -> void:
	self.id = id
	self.identifier = identifier

	self.spritesheet = spritesheet

	self.map = map
	self.cell = cell
	self.facing = facing
