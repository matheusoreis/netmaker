extends PanelContainer
class_name CharacterSelection


var _main: Main

var _characters: Array = []
var _current_index: int = 0


func _ready() -> void:
	_main = get_tree().root.get_node("./Main")
	_update_display()


func update_characters(characters: Array) -> void:
	_characters = characters
	_current_index = 0
	_update_display()


func _is_empty_slot() -> bool:
	return _current_index >= _characters.size()


func _update_display() -> void:
	if _is_empty_slot():
		_show_empty_slot_state()
		return

	_show_character_state(_characters[_current_index])


func _show_empty_slot_state() -> void:
	%Identifier.text = ""
	%New.visible = true
	%Select.visible = false
	%Delete.visible = false
	_clear_preview()


func _show_character_state(character: Array) -> void:
	var identifier: String = character[1] if character.size() > 1 else ""
	var spritesheet: String = character[3] if character.size() > 3 else ""

	%Identifier.text = identifier
	_set_sprite(spritesheet)

	%New.visible = false
	%Select.visible = true
	%Delete.visible = true


func _clear_preview() -> void:
	var atlas: AtlasTexture = %Preview.texture
	atlas.atlas = null


func _set_sprite(spritesheet_name: String) -> void:
	if spritesheet_name.is_empty():
		_clear_preview()
		return

	var path: String = Constants.CHARACTER_SPRITE_DIRECTORY + spritesheet_name + ".png"
	var texture: CompressedTexture2D = load(path)
	if not texture:
		_clear_preview()
		return

	var atlas: AtlasTexture = %Preview.texture
	atlas.atlas = texture


func _get_character_id(character: Array) -> int:
	return character[0] if character.size() > 0 else -1


func _on_back_pressed() -> void:
	if _current_index > 0:
		_current_index -= 1
		_update_display()


func _on_next_pressed() -> void:
	if _current_index < _characters.size():
		_current_index += 1
		_update_display()


func _on_new_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	menu.show_interface(&"CharacterCreation")
	menu.hide_interface(&"CharacterSelection")


func _on_select_pressed() -> void:
	if _is_empty_slot():
		return

	var character_id: int = _get_character_id(_characters[_current_index])
	if character_id != -1:
		Network.exec(&"select_character", [character_id])


func _on_delete_pressed() -> void:
	var menu: Menu = _main.current_scene
	if menu == null:
		return

	if _is_empty_slot():
		return

	var character_id: int = _get_character_id(_characters[_current_index])
	if character_id == -1:
		return

	var confirmation: ConfirmationInterface = menu.get_interface(&"Confirmation")

	confirmation.confirmed.connect(func() -> void:
		Network.exec(&"delete_character", [character_id])
		menu.hide_interface(&"Confirmation")
	, CONNECT_ONE_SHOT)

	confirmation.canceled.connect(func() -> void:
		menu.hide_interface(&"Confirmation")
	, CONNECT_ONE_SHOT)

	confirmation.setup("Tem certeza que deseja apagar este personagem?")
	menu.show_interface(&"Confirmation")
