extends ColorRect

@onready var btn_record = $Layout/Row1/Record
@onready var btn_stop = $Layout/Row1/Stop
@onready var btn_play = $Layout/Row1/PlayButtons/Play
@onready var btn_play_fast = $Layout/Row1/PlayButtons/PlayFast
@onready var progress = $Layout/Row2_5/ProgressBar
@onready var lbl_fps = $Layout/Row2_5/FPS
@onready var chk_record_mouse = $Layout/Row2/RecordMouse
@onready var chk_warp_mouse = $Layout/Row2/WarpMouse
@onready var event_output = $Output/Layout/TabContainer/EventOutput
@onready var tree_recordings = $Layout/Row3/ScrollContainer/Tree
@onready var tree_row = $Layout/Row3


signal play
signal play_fast
signal record
signal stop
signal recorder_selected(input_recorder)
signal save


func _on_record_pressed():
	record.emit()


func _on_stop_pressed():
	stop.emit()


func _on_play_pressed():
	play.emit()


func _on_play_fast_pressed():
	play_fast.emit()


func _on_tree_recorder_selected(input_recorder):
	recorder_selected.emit(input_recorder)


func _on_save_pressed():
	save.emit()


func _process(_delta):
	lbl_fps.text = str("fps: ", Engine.get_frames_per_second())
