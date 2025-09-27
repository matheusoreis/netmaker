class_name Map extends Node2D


@export_category("General")
@export var id: int
@export var identifier: String

@export_category("Settings")
@export var tile_size: int = 32

@export_category("Nodes")
@export var layers: Array[TileMapLayer]
@export var spawn_location: Node2D
