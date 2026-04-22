extends Control
class_name _IR_AllControls
@onready var record_control = %RecordControl
@onready var play_control = %PlayControl
@onready var recordings_control = %InputRecorder



func _ready() -> void:
	normal_mode()
	play_control.player.play_frame.connect(_on_frame_played)
	play_control.player.done.connect(_on_playback_done)

#func _process(delta: float) -> void:
	#if(play_control.player.is_playing):
		#recordings_control.recording_details.highlight_frame(play_control.player._frame_counter)

func play_mode():
	record_control.visible = false
	play_control.visible = true
	recordings_control.show_overlay(true)
	recordings_control.show_recording_details()


func record_mode():
	record_control.visible = true
	play_control.visible = false
	recordings_control.show_overlay(true)
	
	
func normal_mode():
	record_control.visible = false
	play_control.visible = false
	recordings_control.show_overlay(false)
	

func _on_frame_played(which):
	recordings_control.recording_details.highlight_frame(which)

func _on_playback_done():
	recordings_control.recording_details.highlight_none()
