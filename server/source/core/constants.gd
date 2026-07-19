extends RefCounted
class_name Constants


const MAPS_PATH: String = "res://data/maps/"


const HOST: String = "0.0.0.0"
const PORT: int = 7001

const MAX_PEERS: int = 100

const TILE_SIZE: int = 32

const CELL_COLLISION_NONE: int = 0
const CELL_COLLISION_FULL_BLOCK: int = 1
const CELL_COLLISION_NORTH: int = 2
const CELL_COLLISION_EAST: int = 4
const CELL_COLLISION_SOUTH: int = 8
const CELL_COLLISION_WEST: int = 16

const WALKING_SPEED: int = 5

const START_MAP_ID: int = 1
const START_MAP_POSITION: Vector2i = Vector2i(5, 5)
const START_MAP_DIRECTION: Vector2i = Vector2i.DOWN
