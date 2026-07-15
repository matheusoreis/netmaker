extends Node


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


func play_bgm(name: String, volume: float = 1.0, pitch: float = 1.0, loop: bool = true) -> void:
	if name.is_empty():
		return

	var path: String = "res://assets/sfx/bgm/%s.ogg" % name

	if not ResourceLoader.exists(path):
		push_warning("GameAudio: BGM not found: %s" % path)
		return

	_playing_bgm = name
	var stream: AudioStream = load(path)
	_bgm_player.stream = stream
	_bgm_player.volume_db = _linear_to_db(volume)
	_bgm_player.pitch_scale = pitch
	_bgm_player.finished.connect(_on_bgm_finished.bind(loop))
	_bgm_player.play()


func _on_bgm_finished(loop: bool) -> void:
	if loop and not _playing_bgm.is_empty():
		_bgm_player.play()


func stop_bgm() -> void:
	_playing_bgm = ""
	_bgm_player.stop()
	_bgm_player.stream = null
	_bgm_player.finished.disconnect(_on_bgm_finished)


func fade_bgm(time: float) -> void:
	_playing_bgm = ""
	var tween = create_tween()
	tween.tween_property(_bgm_player, "volume_db", -80.0, time)
	tween.tween_callback(stop_bgm)


func memorize_bgm() -> void:
	_memorized_bgm = _playing_bgm


func restore_bgm() -> void:
	play_bgm(_memorized_bgm)


func read_playing_bgm() -> String:
	return _playing_bgm


func play_bgs(name: String, volume: float = 1.0, pitch: float = 1.0, loop: bool = true) -> void:
	if name.is_empty():
		return

	var path: String = "res://assets/sfx/bgs/%s.ogg" % name

	if not ResourceLoader.exists(path):
		push_warning("GameAudio: BGS not found: %s" % path)
		return

	_playing_bgs = name
	var stream: AudioStream = load(path)
	_bgs_player.stream = stream
	_bgs_player.volume_db = _linear_to_db(volume)
	_bgs_player.pitch_scale = pitch
	_bgs_player.finished.connect(_on_bgs_finished.bind(loop))
	_bgs_player.play()


func _on_bgs_finished(loop: bool) -> void:
	if loop and not _playing_bgs.is_empty():
		_bgs_player.play()


func stop_bgs() -> void:
	_playing_bgs = ""
	_bgs_player.stop()
	_bgs_player.stream = null
	_bgs_player.finished.disconnect(_on_bgs_finished)


func fade_bgs(time: float) -> void:
	_playing_bgs = ""
	var tween = create_tween()
	tween.tween_property(_bgs_player, "volume_db", -80.0, time)
	tween.tween_callback(stop_bgs)


func memorize_bgs() -> void:
	_memorized_bgs = _playing_bgs


func restore_bgs() -> void:
	play_bgs(_memorized_bgs)


func read_playing_bgs() -> String:
	return _playing_bgs


func play_me(name: String, volume: float = 1.0, pitch: float = 1.0) -> void:
	if name.is_empty():
		return

	var path: String = "res://assets/sfx/me/%s.ogg" % name

	if not ResourceLoader.exists(path):
		push_warning("GameAudio: ME not found: %s" % path)
		return

	var stream: AudioStream = load(path)
	_me_player.stream = stream
	_me_player.volume_db = _linear_to_db(volume)
	_me_player.pitch_scale = pitch
	_me_player.play()


func play_se(name: String, volume: float = 1.0, pitch: float = 1.0) -> void:
	if name.is_empty():
		return

	var path: String = "res://assets/sfx/se/%s.ogg" % name

	if not ResourceLoader.exists(path):
		push_warning("GameAudio: SE not found: %s" % path)
		return

	var stream: AudioStream = load(path)
	_se_player.stream = stream
	_se_player.volume_db = _linear_to_db(volume)
	_se_player.pitch_scale = pitch
	_se_player.play()


func stop_se() -> void:
	_se_player.stop()
	_se_player.stream = null


func _linear_to_db(value: float) -> float:
	if value <= 0:
		return -80.0
	return 20.0 * log(value) / log(10.0)
