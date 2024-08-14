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
@onready var recording_list = $Layout/Row3/RecordingList
@onready var tree_row = $Layout/Row3
@onready var lbl_file_path = $Layout/Row3/FilePath


signal play
signal play_fast
signal record
signal stop
signal recorder_selected(input_recorder)
signal save
signal save_as(path)
signal load_file(path)

var _load_dlg = null
var _save_dlg = null

func _ready():
	_load_dlg = FileDialog.new()
	_load_dlg.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_load_dlg.file_selected.connect(_on_load_file_selected)
	_load_dlg.add_filter("*.cfg", "ConfigFile")
	add_child(_load_dlg)
	
	_save_dlg = FileDialog.new()
	_save_dlg.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_save_dlg.file_selected.connect(_on_save_as_file_selected)
	_save_dlg.add_filter("*.cfg", "ConfigFile")
	add_child(_save_dlg)
	
	# Hide these for now, maybe forever!
	lbl_fps.visible = false
	btn_play_fast.visible = false

#func _process(_delta):
	#lbl_fps.text = str("fps: ", Engine.get_frames_per_second())


func _on_record_pressed():
	record.emit()


func _on_stop_pressed():
	stop.emit()


func _on_play_pressed():
	play.emit()


func _on_play_fast_pressed():
	play_fast.emit()


func _on_save_pressed():
	save.emit()


func _on_load_pressed():
	_load_dlg.popup_centered(Vector2i(300, 300))
	
	
func _on_load_file_selected(path):
	load_file.emit(path)
	

func _on_save_as_pressed():
	_save_dlg.popup_centered(Vector2i(300, 300))

	
func _on_save_as_file_selected(path):
	save_as.emit(path)
	

func _on_recording_list_recorder_activated(input_recorder):
	play.emit()


func _on_recording_list_recorder_selected(input_recorder):
	recorder_selected.emit(input_recorder)
