## Recurso com dados de mapa compatível com [GridWorld2D].
##
## Pode ser carregado e passado para [method GridWorld2D.setup_from_dict].
extends Resource
class_name GridMapResource


## Identificador único do mapa.
@export var identifier: String = ""

## Tamanho de cada tile em pixels.
@export var tile_size: int = 32

## Posição X da origem do mapa (em coordenadas de grid).
@export var bounds_x: int = 0

## Posição Y da origem do mapa (em coordenadas de grid).
@export var bounds_y: int = 0

## Largura do mapa (em tiles).
@export var bounds_w: int = 0

## Altura do mapa (em tiles).
@export var bounds_h: int = 0

## Array de tiles codificados. Veja [GridMapExporter] para o formato de codificação.
@export var tiles: Array[int] = []


## Gera um dicionário compatível com [method GridWorld2D.setup_from_dict].
func to_dict() -> Dictionary:
	return {
		"identifier": identifier,
		"tile_size": tile_size,
		"bounds_x": bounds_x,
		"bounds_y": bounds_y,
		"bounds_w": bounds_w,
		"bounds_h": bounds_h,
		"tiles": tiles,
	}
