extends Entity
class_name Character


## Identificador da conta proprietária do personagem.
var account: int


## Cria um personagem com os dados informados.
func _init(id: int, identifier: String, spritesheet: String, map: int, cell: Vector2i, facing: Vector2i, account: int) -> void:
	super(id, identifier, spritesheet, map, cell, facing)

	self.account = account


## Move o personagem na direção informada.
func move(direction: Vector2i) -> void:
	facing = direction
	cell += direction
