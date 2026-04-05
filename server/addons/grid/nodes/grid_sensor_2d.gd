## Sensor de entidades do grid. Detecta entidades que entram e saem da área ao redor do dono.
##
## Funciona como uma [Area2D], mas para o grid lógico. Adicione como filho de um
## [GridEntity2D] e arraste um [GridArea2D] filho no export [member area].
## Chame [method bind_to_world] se o mundo for atribuído após o [method _ready].
##
## [codeblock]
## func _ready() -> void:
##     $GridSensor2D.entity_entered.connect(_on_entity_entered)
##     $GridSensor2D.entity_exited.connect(_on_entity_exited)
## [/codeblock]
extends Node2D
class_name GridSensor2D


## Emitido quando uma entidade entra na área do sensor.
signal entity_entered(entity: GridEntity2D)

## Emitido quando uma entidade sai da área do sensor.
signal entity_exited(entity: GridEntity2D)


@export_group("Area")

## Área de detecção. Arraste um [GridArea2D] filho aqui.
@export var area: GridArea2D


@export_group("Filters")

## Se [code]true[/code], o dono não é incluído entre as entidades detectadas.
@export var ignore_owner: bool = true


## Entidade dona do sensor. Resolvida automaticamente se o pai for um [GridEntity2D].
var owner_entity: GridEntity2D = null


var _world: GridMap2D = null
var _detected: Dictionary[GridEntity2D, bool] = {}


func _ready() -> void:
	if get_parent() is GridEntity2D:
		owner_entity = get_parent()

	if owner_entity:
		owner_entity.move_finished.connect(_on_owner_moved)
		if owner_entity.current_world:
			bind_to_world(owner_entity.current_world)


## Retorna todas as entidades atualmente detectadas pelo sensor.
func get_detected_entities() -> Array[GridEntity2D]:
	return _detected.keys()


## Retorna [code]true[/code] se [param entity] está dentro da área do sensor.
func is_detected(entity: GridEntity2D) -> bool:
	return _detected.has(entity)


## Liga o sensor ao [param p_world]. Necessário quando o mundo é atribuído após o [method _ready].
func bind_to_world(p_world: GridMap2D) -> void:
	if _world == p_world:
		return

	if _world:
		_world.entity_moved.disconnect(_on_world_entity_moved)
		_world.entity_added.disconnect(_on_world_entity_added)
		_world.entity_removed.disconnect(_on_world_entity_removed)

	_world      = p_world
	area.world  = _world

	_world.entity_moved.connect(_on_world_entity_moved)
	_world.entity_added.connect(_on_world_entity_added)
	_world.entity_removed.connect(_on_world_entity_removed)

	_scan()


func _scan() -> void:
	if not _world or not owner_entity or not area:
		return

	var exclude: GridEntity2D = owner_entity if ignore_owner else null

	var now: Dictionary[GridEntity2D, bool] = {}
	for e: GridEntity2D in area.get_entities(owner_entity.map_position, exclude):
		now[e] = true

	for e: GridEntity2D in now:
		if not _detected.has(e):
			_detected[e] = true
			entity_entered.emit(e)

	for e: GridEntity2D in _detected.keys():
		if not now.has(e):
			_detected.erase(e)
			entity_exited.emit(e)


func _on_owner_moved(_grid_pos: Vector2i) -> void:
	_scan()


func _on_world_entity_moved(_entity: GridEntity2D, _from: Vector2i, _to: Vector2i) -> void:
	_scan()


func _on_world_entity_added(_entity: GridEntity2D) -> void:
	_scan()


func _on_world_entity_removed(entity: GridEntity2D) -> void:
	if _detected.erase(entity):
		entity_exited.emit(entity)
