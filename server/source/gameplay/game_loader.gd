extends Node


func load_all_maps() -> void:
	var dir = DirAccess.open(Constants.MAPS_PATH)
	if not dir:
		push_error("Não foi possível abrir o diretório: ", Constants.MAPS_PATH)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres") and file_name.begins_with("map_"):
			var map_id = int(file_name.substr(4, 3))

			GameMaps.load_map(map_id)

		file_name = dir.get_next()
	dir.list_dir_end()
