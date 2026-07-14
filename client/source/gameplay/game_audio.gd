extends Node


var _bgm_player: AudioStreamPlayer = null
var _bgs_player: AudioStreamPlayer = null
var _me_player: AudioStreamPlayer = null
var _se_player: AudioStreamPlayer = null

var _playing_bgm: Dictionary = {}
var _playing_bgs: Dictionary = {}

var _memorized_bgm: Dictionary = {}
var _memorized_bgs: Dictionary = {}


func _ready() -> void:
	_setup_players()


func _setup_players() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BgmPlayer"
	add_child(_bgm_player)

	_bgs_player = AudioStreamPlayer.new()
	_bgs_player.name = "BgsPlayer"
	add_child(_bgs_player)

	_me_player = AudioStreamPlayer.new()
	_me_player.name = "MePlayer"
	add_child(_me_player)

	_se_player = AudioStreamPlayer.new()
	_se_player.name = "SePlayer"
	add_child(_se_player)


func play_bgm(bgm: Dictionary) -> void:
	if bgm.is_empty():
		return

	var path: String = "res://assets/sfx/bgm/%s.ogg" % bgm.get("name", "")

	if not ResourceLoader.exists(path):
		push_warning("GameAudio: BGM not found: %s" % path)
		return

	_playing_bgm = bgm
	var stream: AudioStream = load(path)
	_bgm_player.stream = stream
	_bgm_player.volume_db = _linear_to_db(bgm.get("volume", 100) / 100.0)
	_bgm_player.pitch_scale = bgm.get("pitch", 1.0)
	_bgm_player.play()


func stop_bgm() -> void:
	_playing_bgm = {}
	_bgm_player.stop()
	_bgm_player.stream = null


func fade_bgm(time: float) -> void:
	_playing_bgm = {}
	var tween = create_tween()
	tween.tween_property(_bgm_player, "volume_db", -80.0, time)
	tween.tween_callback(stop_bgm)


func memorize_bgm() -> void:
	_memorized_bgm = _playing_bgm.duplicate()


func restore_bgm() -> void:
	play_bgm(_memorized_bgm)


func get_playing_bgm() -> Dictionary:
	return _playing_bgm


func play_bgs(bgs: Dictionary) -> void:
	if bgs.is_empty():
		return

	var path: String = "res://assets/sfx/bgs/%s.ogg" % bgs.get("name", "")

	if not ResourceLoader.exists(path):
		push_warning("GameAudio: BGS not found: %s" % path)
		return

	_playing_bgs = bgs
	var stream: AudioStream = load(path)
	_bgs_player.stream = stream
	_bgs_player.volume_db = _linear_to_db(bgs.get("volume", 100) / 100.0)
	_bgs_player.pitch_scale = bgs.get("pitch", 1.0)
	_bgs_player.play()


func stop_bgs() -> void:
	_playing_bgs = {}
	_bgs_player.stop()
	_bgs_player.stream = null


func fade_bgs(time: float) -> void:
	_playing_bgs = {}
	var tween = create_tween()
	tween.tween_property(_bgs_player, "volume_db", -80.0, time)
	tween.tween_callback(stop_bgs)


func memorize_bgs() -> void:
	_memorized_bgs = _playing_bgs.duplicate()


func restore_bgs() -> void:
	play_bgs(_memorized_bgs)


func get_playing_bgs() -> Dictionary:
	return _playing_bgs


func play_me(me: Dictionary) -> void:
	if me.is_empty():
		return

	var path: String = "res://assets/sfx/me/%s.ogg" % me.get("name", "")

	if not ResourceLoader.exists(path):
		push_warning("GameAudio: ME not found: %s" % path)
		return

	var stream: AudioStream = load(path)
	_me_player.stream = stream
	_me_player.volume_db = _linear_to_db(me.get("volume", 100) / 100.0)
	_me_player.pitch_scale = me.get("pitch", 1.0)
	_me_player.play()


func play_se(se: Dictionary) -> void:
	if se.is_empty():
		return

	var path: String = "res://assets/sfx/se/%s.ogg" % se.get("name", "")

	if not ResourceLoader.exists(path):
		push_warning("GameAudio: SE not found: %s" % path)
		return

	var stream: AudioStream = load(path)
	_se_player.stream = stream
	_se_player.volume_db = _linear_to_db(se.get("volume", 100) / 100.0)
	_se_player.pitch_scale = se.get("pitch", 1.0)
	_se_player.play()


func stop_se() -> void:
	_se_player.stop()
	_se_player.stream = null


func _linear_to_db(value: float) -> float:
	if value <= 0:
		return -80.0
	return 20.0 * log(value) / log(10.0)
