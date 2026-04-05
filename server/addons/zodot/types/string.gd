extends ZodotSchema
class_name ZodotString


func _init(message: String) -> void:
	super._init(message)


func _validate_type(value: Variant) -> bool:
	return value is String


func min_length(length: int, message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		if value.length() < length:
			return message
		return ""
	)
	return self


func max_length(length: int, message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		if value.length() > length:
			return message
		return ""
	)
	return self


func length(len: int, message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		if value.length() != len:
			return message
		return ""
	)
	return self


func regex(pattern: String, message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		var re = RegEx.new()
		re.compile(pattern)
		if not re.search(value):
			return message
		return ""
	)
	return self


func email(message: String) -> ZodotString:
	return regex(r"^[^\s@]+@[^\s@]+\.[^\s@]+$", message)


func uuid(message: String) -> ZodotString:
	return regex(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", message)


func url(message: String) -> ZodotString:
	return regex(r"^https?:\/\/[^\s]+$", message)


func nonempty(message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		if value.is_empty():
			return message
		return ""
	)
	return self


func lowercase(message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		if value != value.to_lower():
			return message
		return ""
	)
	return self


func uppercase(message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		if value != value.to_upper():
			return message
		return ""
	)
	return self


func starts_with(prefix: String, message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		if not value.begins_with(prefix):
			return message
		return ""
	)
	return self


func ends_with(suffix: String, message: String) -> ZodotString:
	_checks.append(func(value: String) -> String:
		if not value.ends_with(suffix):
			return message
		return ""
	)
	return self


func alphanumeric(message: String) -> ZodotString:
	return regex(r"^[a-zA-Z0-9]*$", message)


func numeric(message: String) -> ZodotString:
	return regex(r"^[0-9]*$", message)


func hex(message: String) -> ZodotString:
	return regex(r"^[0-9a-fA-F]*$", message)


func base64(message: String) -> ZodotString:
	return regex(r"^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$", message)
