extends ZodotSchema
class_name ZodotVector2


func _init(message: String) -> void:
	super._init(message)


func _validate_type(value: Variant) -> bool:
	return value is Vector2


func length(min_len: float, max_len: float, message: String) -> ZodotVector2:
	_checks.append(func(v: Vector2) -> String:
		var len = v.length()
		if len < min_len or len > max_len:
			return message
		return ""
	)
	return self


func min_component(value: float, message: String) -> ZodotVector2:
	_checks.append(func(v: Vector2) -> String:
		if v.x < value or v.y < value:
			return message
		return ""
	)
	return self


func max_component(value: float, message: String) -> ZodotVector2:
	_checks.append(func(v: Vector2) -> String:
		if v.x > value or v.y > value:
			return message
		return ""
	)
	return self


func not_zero(message: String) -> ZodotVector2:
	_checks.append(func(v: Vector2) -> String:
		if v == Vector2.ZERO:
			return message
		return ""
	)
	return self


func normalized(message: String) -> ZodotVector2:
	_checks.append(func(v: Vector2) -> String:
		if not v.is_normalized():
			return message
		return ""
	)
	return self