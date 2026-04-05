extends ZodotSchema
class_name ZodotDictionary


var _shape: Dictionary


func _init(shape: Dictionary, message: String) -> void:
	super._init(message)
	_shape = shape


func _validate_type(value: Variant) -> bool:
	return value is Dictionary


func validate(value: Variant, path: Array[String] = []) -> ZodotResult:
	if not _validate_type(value):
		if value == null and (_is_optional or _is_nullable or _has_default):
			if _has_default:
				return ZodotResult.ok(_default_value)
			return ZodotResult.ok(null)
		return ZodotResult.fail([ZodotError.new(path, _type_message)])
	
	var dict = value as Dictionary
	var errors: Array[ZodotError] = []
	var validated_dict: Dictionary = {}
	
	for key: Variant in _shape.keys():
		var schema: ZodotSchema = _shape[key]
		var field_value = dict.get(key)
		
		var field_path = path.duplicate()
		field_path.append(str(key))
		
		var result = schema.validate(field_value, field_path)
		if not result.success:
			errors.append_array(result.errors)
		else:
			validated_dict[key] = result.data
	
	for check in _checks:
		var result = check.call(dict)
		if result is String and not result.is_empty():
			errors.append(ZodotError.new(path, result))
		elif result is Dictionary:
			var msg = result.get("message", "Erro de validação")
			errors.append(ZodotError.new(path, msg, result.get("context")))
	
	if not errors.is_empty():
		return ZodotResult.fail(errors)
	
	return ZodotResult.ok(validated_dict)