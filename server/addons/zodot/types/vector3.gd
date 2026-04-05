extends ZodotSchema
class_name ZodotVector3


func _init(message: String) -> void:
	super._init(message)


func _validate_type(value: Variant) -> bool:
	return value is Vector3


func length(min_len: float, max_len: float, message: String) -> ZodotVector3:
	_checks.append(func(v: Vector3) -> String:
		var len = v.length()
		if len < min_len or len > max_len:
			return message
		return ""
	)
	return self


func min_component(value: float, message: String) -> ZodotVector3:
	_checks.append(func(v: Vector3) -> String:
		if v.x < value or v.y < value or v.z < value:
			return message
		return ""
	)
	return self


func max_component(value: float, message: String) -> ZodotVector3:
	_checks.append(func(v: Vector3) -> String:
		if v.x > value or v.y > value or v.z > value:
			return message
		return ""
	)
	return self


func not_zero(message: String) -> ZodotVector3:
	_checks.append(func(v: Vector3) -> String:
		if v == Vector3.ZERO:
			return message
		return ""
	)
	return self


func normalized(message: String) -> ZodotVector3:
	_checks.append(func(v: Vector3) -> String:
		if not v.is_normalized():
			return message
		return ""
	)
	return self