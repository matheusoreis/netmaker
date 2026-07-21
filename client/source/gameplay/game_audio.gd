extends Node


const _CATEGORY_PATHS: Dictionary[String, String] = {
	"bgm": "res://assets/sfx/bgm/%s.ogg",
	"bgs": "res://assets/sfx/bgs/%s.ogg",
	"me": "res://assets/sfx/me/%s.ogg",
	"se": "res://assets/sfx/se/%s.ogg",
}


var _bgm_player: AudioStreamPlayer = null
var _bgs_player: AudioStreamPlayer = null
var _me_player: AudioStreamPlayer = null
var _se_player: AudioStreamPlayer = null

var _playing_bgm: String = ""
var _playing_bgs: String = ""

var _memorized_bgm: String = ""
var _memorized_bgs: String = ""


func _ready() -> void:
	_setup_players()


func _setup_players() -> void:
	_bgm_player = _make_player("BgmPlayer")
	_bgs_player = _make_player("BgsPlayer")
	_me_player = _make_player("MePlayer")
	_se_player = _make_player("SePlayer")


func _make_player(player_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	add_child(player)
	return player


func play_bgm(name: String, volume: float = 1.0, pitch: float = 1.0, loop: bool = true) -> void:
	var stream: AudioStream = _load_stream("bgm", name)
	if not stream:
		return

	_playing_bgm = name
	_play_on(_bgm_player, stream, volume, pitch, loop)


func stop_bgm() -> void:
	_playing_bgm = ""
	_stop(_bgm_player)


func fade_bgm(time: float) -> void:
	_playing_bgm = ""
	_fade_out(_bgm_player, time, stop_bgm)


func memorize_bgm() -> void:
	_memorized_bgm = _playing_bgm


func restore_bgm() -> void:
	play_bgm(_memorized_bgm)


func read_playing_bgm() -> String:
	return _playing_bgm


func play_bgs(name: String, volume: float = 1.0, pitch: float = 1.0, loop: bool = true) -> void:
	var stream: AudioStream = _load_stream("bgs", name)
	if not stream:
		return

	_playing_bgs = name
	_play_on(_bgs_player, stream, volume, pitch, loop)


func stop_bgs() -> void:
	_playing_bgs = ""
	_stop(_bgs_player)


func fade_bgs(time: float) -> void:
	_playing_bgs = ""
	_fade_out(_bgs_player, time, stop_bgs)


func memorize_bgs() -> void:
	_memorized_bgs = _playing_bgs


func restore_bgs() -> void:
	play_bgs(_memorized_bgs)


func read_playing_bgs() -> String:
	return _playing_bgs


func play_me(name: String, volume: float = 1.0, pitch: float = 1.0) -> void:
	var stream: AudioStream = _load_stream("me", name)
	if not stream:
		return

	_play_on(_me_player, stream, volume, pitch, false)


func play_se(name: String, volume: float = 1.0, pitch: float = 1.0) -> void:
	var stream: AudioStream = _load_stream("se", name)
	if not stream:
		return

	_play_on(_se_player, stream, volume, pitch, false)


func stop_se() -> void:
	_stop(_se_player)


## Resolve o path de uma categoria (bgm/bgs/me/se) e carrega o stream,
## avisando (sem quebrar) se o arquivo não existir.
func _load_stream(category: String, name: String) -> AudioStream:
	if name.is_empty():
		return null

	var path: String = _CATEGORY_PATHS[category] % name
	if not ResourceLoader.exists(path):
		push_warning("GameAudio: %s não encontrado: %s" % [category.to_upper(), path])
		return null

	return load(path)


func _play_on(player: AudioStreamPlayer, stream: AudioStream, volume: float, pitch: float, loop: bool) -> void:
	player.stream = stream
	player.volume_db = _linear_to_db(volume)
	player.pitch_scale = pitch
	player.stream.loop = loop
	player.play()


func _stop(player: AudioStreamPlayer) -> void:
	player.stop()
	player.stream = null


func _fade_out(player: AudioStreamPlayer, time: float, on_complete: Callable) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, time)
	tween.tween_callback(on_complete)


func _linear_to_db(value: float) -> float:
	if value <= 0:
		return -80.0
	return 20.0 * log(value) / log(10.0)
