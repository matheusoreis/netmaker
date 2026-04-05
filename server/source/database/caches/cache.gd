extends RefCounted
class_name Cache


var _repository: Repository

var entries: Dictionary[int, Model] = {}


func _init(repository: Repository) -> void:
	_repository = repository


func load_all() -> void:
	pass
