extends ZodotSchema
class_name ZodotVector3i


func _init(message: String) -> void:
	super._init(message)


func _validate_type(value: Variant) -> bool:
	return value is Vector3i


func min_component(value: int, message: String) -> ZodotVector3i:
	_checks.append(func(v: Vector3i) -> String:
		if v.x < value or v.y < value or v.z < value:
			return message
		return ""
	)
	return self


func max_component(value: int, message: String) -> ZodotVector3i:
	_checks.append(func(v: Vector3i) -> String:
		if v.x > value or v.y > value or v.z > value:
			return message
		return ""
	)
	return self


func not_zero(message: String) -> ZodotVector3i:
	_checks.append(func(v: Vector3i) -> String:
		if v == Vector3i.ZERO:
			return message
		return ""
	)
	return self