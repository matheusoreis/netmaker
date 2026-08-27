extends PanelContainer
class_name CharacterCreationInterface


var _main: Main

var _sprites: Array[CompressedTexture2D] = []
var _sprite_names: Array[String] = []
var _current_index: int = 0


func _ready() -> void:
	_main = get_tree().root.get_node("./Main")

	_load_sprites_from_directory()
	_update_preview()


func _load_sprites_from_directory() -> void:
	var dir: DirAccess = DirAccess.open(Constants.CHARACTER_SPRITE_DIRECTORY)
	if not dir:
		return

	dir.list_dir_begin()

	var file_name: String = dir.get_next()
	while file_name != "":
		if _is_png_file(dir, file_name):
			_try_load_sprite(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()


func _is_png_file(dir: DirAccess, file_name: String) -> bool:
	return not dir.current_is_dir() and file_name.ends_with(".png")


func _try_load_sprite(file_name: String) -> void:
	var full_path: String = Constants.CHARACTER_SPRITE_DIRECTORY + file_name
	var texture: CompressedTexture2D = load(full_path)
	if not texture:
		return

	_sprites.append(texture)
	_sprite_names.append(file_name.replace(".png", ""))


func _update_preview() -> void:
	if _sprites.is_empty():
		return

	var atlas: AtlasTexture = %Preview.texture
	atlas.atlas = _sprites[_current_index]


func _show_alert(menu: Menu, message: String) -> void:
	var alert: AlertInterface = menu.get_interface(&"Alert")

	alert.confirmed.connect(func() -> void:
		menu.hide_interface(&"Alert")
	, CONNECT_ONE_SHOT)

	alert.setup(message)
	menu.show_interface(&"Alert")


func _validate_identifier(identifier: String) -> String:
	if identifier.is_empty():
		return "Informe o nome e tente novamente!"

	return ""


func _on_back_pressed() -> void:
	if _sprites.is_empty():
		return

	_current_index = (_current_index - 1 + _sprites.size()) % _sprites.size()
	_update_preview()


func _on_next_pressed() -> void:
	if _sprites.is_empty():
		return

	_current_index = (_current_index + 1) % _sprites.size()
	_update_preview()


func _on_confirm_pressed() -> void:
	if _sprites.is_empty():
		return

	var menu: Menu = _main.current_scene
	if menu == null:
		return

	var identifier: String = %Identifier.text

	var error: String = _validate_identifier(identifier)
	if not error.is_empty():
		_show_alert(menu, error)
		return

	var selected_name: String = _sprite_names[_current_index]
	Network.exec(&"create_character", [identifier, selected_name])


func _on_close_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	menu.show_interface(&"CharacterSelection")
	menu.hide_interface(&"CharacterCreation")
