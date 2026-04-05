extends ZodotSchema
class_name ZodotEnum


var _values: Array


func _init(values: Array, message: String) -> void:
	super._init(message)
	_values = values


func _validate_type(value: Variant) -> bool:
	return value in _values