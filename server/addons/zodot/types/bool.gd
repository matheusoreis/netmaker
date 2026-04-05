extends ZodotSchema
class_name ZodotBool


func _init(message: String) -> void:
	super._init(message)


func _validate_type(value: Variant) -> bool:
	return value is bool