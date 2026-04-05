## Nó utilitário de editor para extrair dados de [TileMapLayer]s e gerar
## um [GridMapResource] (.tres) compatível com [GridWorld2D].
##
## Campos esperados no TileSet (Custom Data Layers):[br]
## [code]"block"[/code] ([bool]) — tile totalmente bloqueado.[br]
## [code]"block_directions"[/code] ([code]Array[Vector2i][/code]) — direções cardinais bloqueadas.[br]
@tool
extends Node
class_name GridMapExporter


@export_category("Map Settings")

## Nome único que identifica o mapa. Usado como chave primária no resource.
@export var identifier: String = ""

## Tamanho de cada tile em pixels.
@export var tile_size: int = 32

@export_category("Layers")

## Camadas do TileMap a serem processadas. Dados de camadas sobrepostas são mesclados.
@export var layers: Array[TileMapLayer] = []

@export_category("Output")

## Diretório onde o arquivo [code].tres[/code] será salvo.
@export_dir var output_path: String = "res://maps/"

@export_category("Debug")

## Se [code]true[/code], imprime os dados de cada tile processado no console.
@export var debug_mode: bool = false

@export_tool_button("Export Map", "Save") var _export_button: Callable = func() -> void: export_map()


## Processa as camadas, cria e salva um [GridMapResource] em arquivo.
## Só funciona quando executado no editor.
func export_map() -> void:
	if not Engine.is_editor_hint():
		return
	if identifier.strip_edges() == "":
		push_error("GridMapExporter: 'identifier' não pode ser vazio.")
		return
	if layers.is_empty():
		push_error("GridMapExporter: nenhuma camada atribuída.")
		return

	var resource: GridMapResource = _build_resource()
	if resource == null:
		return

	_save_to_file(resource)


func _build_resource() -> GridMapResource:
	var bounds: Rect2i = Rect2i()
	var has_bounds: bool = false

	for layer: TileMapLayer in layers:
		if layer == null:
			continue
		var used: Rect2i = layer.get_used_rect()
		if used.size == Vector2i.ZERO:
			continue
		bounds = used if not has_bounds else bounds.merge(used)
		has_bounds = true

	if not has_bounds:
		push_error("GridMapExporter: nenhuma camada possui tiles.")
		return null

	var width: int = bounds.size.x
	var height: int = bounds.size.y
	var total: int = width * height

	var tiles: Array[int] = []
	tiles.resize(total)
	for i: int in total:
		tiles[i] = 0

	for x: int in width:
		for y: int in height:
			var grid_pos: Vector2i = bounds.position + Vector2i(x, y)
			var idx: int = x * height + y

			var blocked: bool = false
			var dirs: Array[Vector2i] = []

			for layer: TileMapLayer in layers:
				if layer == null:
					continue
				if layer.get_cell_source_id(grid_pos) == -1:
					continue
				var tile_data: TileData = layer.get_cell_tile_data(grid_pos)
				if tile_data == null:
					continue

				if _read_blocked(tile_data):
					blocked = true
				for dir: Vector2i in _read_directions(tile_data):
					if not dirs.has(dir):
						dirs.append(dir)

			if blocked or not dirs.is_empty():
				tiles[idx] = _encode_tile(blocked, dirs)

				if debug_mode:
					print("  (%d,%d) blocked=%s dirs=%s" % [
						grid_pos.x, grid_pos.y, blocked, dirs
					])

	var resource: GridMapResource = GridMapResource.new()
	resource.identifier = identifier
	resource.tile_size = tile_size
	resource.bounds_x = bounds.position.x
	resource.bounds_y = bounds.position.y
	resource.bounds_w = bounds.size.x
	resource.bounds_h = bounds.size.y
	resource.tiles = tiles

	print("GridMapExporter: Resource criado (%dx%d, %d tiles)" % [bounds.size.x, bounds.size.y, total])
	return resource


func _save_to_file(resource: GridMapResource) -> void:
	if not DirAccess.dir_exists_absolute(output_path):
		DirAccess.make_dir_recursive_absolute(output_path)

	var file_path: String = output_path.path_join(identifier.to_lower() + ".tres")
	var error: Error = ResourceSaver.save(resource, file_path)

	if error != OK:
		push_error("GridMapExporter: falha ao salvar '%s' (erro %d)." % [file_path, error])
		return

	print("GridMapExporter: Mapa salvo em '%s'." % file_path)


func _encode_tile(blocked: bool, dirs: Array[Vector2i]) -> int:
	var raw: int = 0x01 if blocked else 0
	for dir: Vector2i in dirs:
		match dir:
			Vector2i(-1,  0): raw |= 0x02
			Vector2i( 1,  0): raw |= 0x04
			Vector2i( 0, -1): raw |= 0x08
			Vector2i( 0,  1): raw |= 0x10
	return raw


func _read_blocked(tile_data: TileData) -> bool:
	var val: Variant = tile_data.get_custom_data("block")
	return val is bool and (val as bool)


func _read_directions(tile_data: TileData) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var val: Variant = tile_data.get_custom_data("block_directions")
	if val is Array:
		for entry: Variant in val as Array:
			if entry is Vector2i:
				result.append(entry as Vector2i)
	return result
