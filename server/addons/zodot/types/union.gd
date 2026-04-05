extends ZodotSchema
class_name ZodotUnion


var _schemas: Array[ZodotSchema]


func _init(schemas: Array, message: String) -> void:
	super._init(message)
	_schemas = schemas


func _validate_type(_value: Variant) -> bool:
	return true


func validate(value: Variant, path: Array[String] = []) -> ZodotResult:
	var last_errors: Array[ZodotError] = []
	
	for schema in _schemas:
		var result = schema.validate(value, path)
		if result.success:
			return result
		last_errors = result.errors
	
	return ZodotResult.fail([ZodotError.new(path, _type_message)])