extends ZodotSchema
class_name ZodotVector2i


func _init(message: String) -> void:
	super._init(message)


func _validate_type(value: Variant) -> bool:
	return value is Vector2i


func min_component(value: int, message: String) -> ZodotVector2i:
	_checks.append(func(v: Vector2i) -> String:
		if v.x < value or v.y < value:
			return message
		return ""
	)
	return self


func max_component(value: int, message: String) -> ZodotVector2i:
	_checks.append(func(v: Vector2i) -> String:
		if v.x > value or v.y > value:
			return message
		return ""
	)
	return self


func not_zero(message: String) -> ZodotVector2i:
	_checks.append(func(v: Vector2i) -> String:
		if v == Vector2i.ZERO:
			return message
		return ""
	)
	return self