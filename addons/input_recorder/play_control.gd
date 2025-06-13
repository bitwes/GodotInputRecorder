extends ColorRect


@onready var _prog_bar = $VBoxContainer/ProgressBar
@onready var _pause_btn = $VBoxContainer/Buttons/Pause
@onready var _resume_btn = $VBoxContainer/Buttons/Resume
@onready var _stop_btn = $VBoxContainer/Buttons/Stop


var player : IR_Player


func _ready() -> void:
	player = IR_Player.new()
	add_child(player)


func _process(_delta):
	if(player.is_playing):
		_prog_bar.value = player.percent_complete()


func _on_stop_pressed() -> void:
	_stop_btn.disabled = true
	_pause_btn.disabled = true
	_resume_btn.disabled = true

	stop()


func _on_pause_pressed() -> void:
	player.pause()
	_pause_btn.disabled = true
	_resume_btn.disabled = false


func _on_resume_pressed() -> void:
	player.resume()
	_pause_btn.disabled = false
	_resume_btn.disabled = true


func play(recording):
	_stop_btn.disabled = false
	_pause_btn.disabled = false
	_resume_btn.disabled = true
	_prog_bar.value = 0
	
	player.play_input_queue(recording)


func stop():
	player.stop()
