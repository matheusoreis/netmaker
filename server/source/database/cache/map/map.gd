extends Node
class_name MapCache

@export var maps_data: Array[GridMapData] = []

var maps: Dictionary[String, GameMap] = {}


func initialize() -> void:
	for map_data: GridMapData in maps_data:
		if map_data == null or map_data.identifier.is_empty():
			push_warning("[MAP] MapData inválido ou sem identifier, pulando.")
			continue

		_setup_map(map_data)

	print("[MAP] %d mapa(s) carregado(s)." % maps.size())


func get_map(identifier: String) -> GameMap:
	return maps.get(identifier)


func has_map(identifier: String) -> bool:
	return maps.has(identifier)


func _setup_map(map_data: GridMapData) -> void:
	var map: GameMap = GameMap.new()

	map.name = map_data.identifier
	map.map_data = map_data

	add_child(map)

	maps[map_data.identifier] = map
