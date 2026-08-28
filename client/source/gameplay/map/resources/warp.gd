extends Resource
class_name MapWarpData


## Posição da célula de origem da passagem.
@export var from_cell: Vector2i
## Identificador do mapa de destino.
@export var to_map_id: int
## Posição da célula de destino.
@export var to_cell: Vector2i
## Direção inicial no mapa de destino.
@export var to_facing: Vector2i = Vector2i.DOWN
