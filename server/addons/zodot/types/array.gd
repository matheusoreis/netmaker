extends ZodotSchema
class_name ZodotArray


var _item_schema: ZodotSchema


func _init(item_schema: ZodotSchema, message: String) -> void:
	super._init(message)
	_item_schema = item_schema


func _validate_type(value: Variant) -> bool:
	return value is Array


func validate(value: Variant, path: Array[String] = []) -> ZodotResult:
	if not _validate_type(value):
		if value == null and (_is_optional or _is_nullable or _has_default):
			if _has_default:
				return ZodotResult.ok(_default_value)
			return ZodotResult.ok(null)
		return ZodotResult.fail([ZodotError.new(path, _type_message)])

	var arr = value as Array
	var errors: Array[ZodotError] = []
	var validated_array: Array = []

	for i in range(arr.size()):
		var item_path = path.duplicate()
		item_path.append(str(i))

		var result = _item_schema.validate(arr[i], item_path)
		if not result.success:
			errors.append_array(result.errors)
		else:
			validated_array.append(result.data)

	for check in _checks:
		var result = check.call(arr)
		if result is String and not result.is_empty():
			errors.append(ZodotError.new(path, result))
		elif result is Dictionary:
			var msg = result.get("message", "Erro de validação")
			errors.append(ZodotError.new(path, msg, result.get("context")))

	if not errors.is_empty():
		return ZodotResult.fail(errors)

	return ZodotResult.ok(validated_array)


func min_length(length: int, message: String) -> ZodotArray:
	_checks.append(func(arr: Array) -> String:
		if arr.size() < length:
			return message
		return ""
	)
	return self


func max_length(length: int, message: String) -> ZodotArray:
	_checks.append(func(arr: Array) -> String:
		if arr.size() > length:
			return message
		return ""
	)
	return self


func length(len: int, message: String) -> ZodotArray:
	_checks.append(func(arr: Array) -> String:
		if arr.size() != len:
			return message
		return ""
	)
	return self


func nonempty(message: String) -> ZodotArray:
	_checks.append(func(arr: Array) -> String:
		if arr.is_empty():
			return message
		return ""
	)
	return self
