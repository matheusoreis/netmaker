extends PanelContainer
class_name AlertUi

@onready var message_label: Label = %MessageLabel
@onready var hide_timer: Timer = %HideTimer
@onready var progress_bar: ProgressBar = %HideProgress


func _process(_delta: float) -> void:
	if not hide_timer.is_stopped():
		var t := hide_timer.time_left / hide_timer.wait_time
		progress_bar.value = t


func show_message(message: String) -> void:
	message_label.text = message
	show()
	hide_timer.start()


func _on_close_button_pressed() -> void:
	hide()


func _on_hide_timer_timeout() -> void:
	hide()


func _on_mouse_entered() -> void:
	hide_timer.paused = true


func _on_mouse_exited() -> void:
	hide_timer.paused = false
