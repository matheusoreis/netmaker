extends Node


const SHADER_PATH: String = "res://assets/gfx/shader/nopixel.gdshader"
const DEFAULT_AA_SCALE: float = 8.0


const TARGET_CLASSES := [
	"Sprite2D",
	"TileMapLayer",
]

var shader_material: ShaderMaterial

var _enabled: bool = true
var _aa_scale: float = DEFAULT_AA_SCALE


var _managed_nodes: Dictionary = {}


func _ready() -> void:
	var shader: Resource = load(SHADER_PATH)
	if shader == null:
		push_error("Upscale: não encontrei o shader em " + SHADER_PATH)
		return

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("AA_SCALE", _aa_scale)

	_apply_to_tree(get_tree().root)

	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)


func set_enabled(value: bool) -> void:
	if _enabled == value:
		return

	_enabled = value

	for node in _managed_nodes.keys():
		if not is_instance_valid(node):
			continue

		if _enabled:
			node.material = shader_material
		else:
			node.material = null


func toggle_enabled() -> bool:
	set_enabled(!_enabled)
	return _enabled


func is_enabled() -> bool:
	return _enabled


func set_aa_scale(value: float) -> void:
	_aa_scale = value
	if shader_material:
		shader_material.set_shader_parameter("AA_SCALE", _aa_scale)


func get_aa_scale() -> float:
	return _aa_scale


func _on_node_added(node: Node) -> void:
	_try_apply(node)


func _on_node_removed(node: Node) -> void:
	_managed_nodes.erase(node)


func _apply_to_tree(node: Node) -> void:
	_try_apply(node)
	for child in node.get_children():
		_apply_to_tree(child)


func _try_apply(node: Node) -> void:
	for class_name_str in TARGET_CLASSES:
		if node.is_class(class_name_str):
			_managed_nodes[node] = null
			if _enabled:
				node.material = shader_material
			return
