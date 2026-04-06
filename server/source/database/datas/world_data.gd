extends Resource
class_name WorldData


## Array de mapas do jogo. O índice é o map_id (igual ao RPG Maker).
@export var maps: Array[GridMapResource] = []


## Retorna o [GridMapResource] do mapa com o [param map_id] informado.
## Retorna [code]null[/code] se o id for inválido.
func get_map(map_id: int) -> GridMapResource:
	if map_id < 0 or map_id >= maps.size():
		return null
	return maps[map_id]


## Retorna [code]true[/code] se o [param map_id] é válido.
func has_map(map_id: int) -> bool:
	return map_id >= 0 and map_id < maps.size()
