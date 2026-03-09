extends Node
class_name Main

const MOVE_INTERVAL: float = 0.15

@export_category("Configuration")
@export_group("Network")
@export var _address: String = "127.0.0.1"
@export_range(1, 65535) var _port: int = 7720
@export_range(1, 32) var _max_channels: int = 3
@export_range(0, 60000, 1, "suffix:ms") var _connection_poll_time: int = 0
@export_range(1, 10240) var _max_tasks: int = 2048

@export_group("Database")
@export_dir var _database_path: String = "user://client/"
@export var _database_filename: String = "client"
@export_range(0, 60000, 1, "suffix:ms") var _database_poll_time: int = 0

@export_category("Gameplay")
@export var _player_scene: PackedScene
@export var _map: GridMap2D

var _database: Database
var _network: Network
var _local_player: Player = null
var _remote_players: Dictionary[int, Player] = {}
var _move_timer: float = MOVE_INTERVAL
var _last_direction: Vector2i = Vector2i.ZERO


func _ready() -> void:
	_database = Database.new()
	_database.initialize(_database_path, _database_filename)

	_network = Network.new()
	_network.initialize(_address, _port, _max_channels, _max_tasks)
	_network.peer_connected.connect(_on_connected)
	_network.peer_disconnected.connect(_on_disconnected)

	_network.register("network", [
		set_id,
	])

	_network.register("game.map", [
		player_spawned,
		player_self_spawned,
		player_despawned,
		player_moved,
		player_position_corrected,
	])


func _process(delta: float) -> void:
	if _database:
		_database.poll(_database_poll_time)
	if _network:
		_network.poll(_connection_poll_time)

	_process_movement(delta)


func _process_movement(delta: float) -> void:
	if not _local_player:
		return

	var direction: Vector2i = Vector2i.ZERO

	if Input.is_action_pressed("ui_up"):
		direction = Vector2i(0, -1)
	elif Input.is_action_pressed("ui_down"):
		direction = Vector2i(0, 1)
	elif Input.is_action_pressed("ui_left"):
		direction = Vector2i(-1, 0)
	elif Input.is_action_pressed("ui_right"):
		direction = Vector2i(1, 0)

	if direction == Vector2i.ZERO:
		_move_timer = MOVE_INTERVAL
		_last_direction = Vector2i.ZERO
		return

	if direction != _last_direction:
		_move_timer = MOVE_INTERVAL
		_last_direction = direction

	_move_timer += delta
	if _move_timer < MOVE_INTERVAL:
		return

	_move_timer = 0.0

	_local_player.move(direction)

	_network.exec("game.map.move", func(buf: StreamPeerBuffer) -> void:
		buf.put_8(direction.x)
		buf.put_8(direction.y)
	)


func set_id(buf: StreamPeerBuffer) -> void:
	var my_id: int = buf.get_u32()
	print("[CLIENT] Meu ID é: %d" % my_id)

	_local_player = _player_scene.instantiate() as Player
	_local_player.entity_id = my_id
	_local_player.setup_as_local()
	_map.add_entity(_local_player, Vector2i(5, 5))

	_network.exec("game.map.entered")


func player_self_spawned(buf: StreamPeerBuffer) -> void:
	var entity_id: int = buf.get_u32()
	var spawn_pos: Vector2i = Vector2i(buf.get_16(), buf.get_16())

	if _local_player == null:
		return

	_local_player.go_to(spawn_pos)
	print("[CLIENT] Minha posição confirmada: %s" % spawn_pos)


func player_spawned(buf: StreamPeerBuffer) -> void:
	var entity_id: int = buf.get_u32()
	var spawn_pos: Vector2i = Vector2i(buf.get_16(), buf.get_16())

	var player: Player = _player_scene.instantiate() as Player
	player.entity_id = entity_id
	player.setup_as_remote()
	_remote_players[entity_id] = player
	_map.add_entity(player, spawn_pos)

	print("[CLIENT] Jogador %d spawnado em %s" % [entity_id, spawn_pos])


func player_despawned(buf: StreamPeerBuffer) -> void:
	var entity_id: int = buf.get_u32()

	var player: Player = _remote_players.get(entity_id)
	if player == null:
		return

	_map.remove_entity(player)
	player.queue_free()
	_remote_players.erase(entity_id)

	print("[CLIENT] Jogador %d removido" % entity_id)


func player_moved(buf: StreamPeerBuffer) -> void:
	var entity_id: int = buf.get_u32()
	var direction: Vector2i = Vector2i(buf.get_8(), buf.get_8())

	var player: Player = _remote_players.get(entity_id)
	if player == null:
		return

	player.move(direction)
	print("[CLIENT] Jogador %d moveu: %s" % [entity_id, direction])


func player_position_corrected(buf: StreamPeerBuffer) -> void:
	var correct_pos: Vector2i = Vector2i(buf.get_16(), buf.get_16())

	if _local_player == null:
		return

	_local_player.go_to(correct_pos)
	print("[CLIENT] Posição corrigida para: %s" % correct_pos)


func _on_connected(_peer_id: int) -> void:
	print("[CLIENT] Conectado ao servidor!")


func _on_disconnected(_peer_id: int) -> void:
	print("[CLIENT] Desconectado do servidor.")

	if _local_player:
		_map.remove_entity(_local_player)
		_local_player.queue_free()
		_local_player = null

	for player: Player in _remote_players.values():
		_map.remove_entity(player)
		player.queue_free()
	_remote_players.clear()
