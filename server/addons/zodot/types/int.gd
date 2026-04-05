extends ZodotSchema
class_name ZodotInt


func _init(message: String) -> void:
	super._init(message)


func _validate_type(value: Variant) -> bool:
	return value is int


func min_value(min_val: int, message: String) -> ZodotInt:
	_checks.append(func(v: int) -> String:
		if v < min_val:
			return message
		return ""
	)
	return self


func max_value(max_val: int, message: String) -> ZodotInt:
	_checks.append(func(v: int) -> String:
		if v > max_val:
			return message
		return ""
	)
	return self


func positive(message: String) -> ZodotInt:
	_checks.append(func(v: int) -> String:
		if v <= 0:
			return message
		return ""
	)
	return self


func negative(message: String) -> ZodotInt:
	_checks.append(func(v: int) -> String:
		if v >= 0:
			return message
		return ""
	)
	return self


func multiple_of(factor: int, message: String) -> ZodotInt:
	_checks.append(func(v: int) -> String:
		if v % factor != 0:
			return message
		return ""
	)
	return self