extends RefCounted
class_name MapModule


## Mapas carregados indexados pelo identificador do mapa.
var _maps: Dictionary[int, Map] = {}


## Adiciona um mapa ao módulo.
func add(map: Map) -> void:
	if has(map.id):
		return
	_maps[map.id] = map


## Remove um mapa pelo seu identificador.
func remove(map_id: int) -> void:
	if not has(map_id):
		return
	_maps.erase(map_id)


## Retorna um mapa pelo seu identificador.
func map(map_id: int) -> Map:
	return _maps.get(map_id)


## Indica se existe um mapa com o identificador informado.
func has(map_id: int) -> bool:
	return _maps.has(map_id)


## Retorna a quantidade de mapas carregados.
func count() -> int:
	return _maps.size()


## Retorna todos os mapas carregados.
func all() -> Array[Map]:
	return _maps.values()


## Remove todos os mapas carregados.
func clear() -> void:
	_maps.clear()
