extends ZodotSchema
class_name ZodotFloat


func _init(message: String) -> void:
	super._init(message)


func _validate_type(value: Variant) -> bool:
	return value is float or value is int


func min_value(min_val: float, message: String) -> ZodotFloat:
	_checks.append(func(v: float) -> String:
		if v < min_val:
			return message
		return ""
	)
	return self


func max_value(max_val: float, message: String) -> ZodotFloat:
	_checks.append(func(v: float) -> String:
		if v > max_val:
			return message
		return ""
	)
	return self


func positive(message: String) -> ZodotFloat:
	_checks.append(func(v: float) -> String:
		if v <= 0.0:
			return message
		return ""
	)
	return self


func negative(message: String) -> ZodotFloat:
	_checks.append(func(v: float) -> String:
		if v >= 0.0:
			return message
		return ""
	)
	return self


func finite(message: String) -> ZodotFloat:
	_checks.append(func(v: float) -> String:
		if is_inf(v) or is_nan(v):
			return message
		return ""
	)
	return self