extends Control

@onready var btn_play = $BaseControl/Layout/Row1/PlayButtons/Play
@onready var btn_play_fast = $BaseControl/Layout/Row1/PlayButtons/PlayFast
@onready var btn_record = $BaseControl/Layout/Row1/Record
@onready var btn_save = $BaseControl/Layout/Row3/Buttons/Save
@onready var btn_stop = $BaseControl/Layout/Row1/Stop
@onready var chk_record_mouse = $BaseControl/Layout/Row2/RecordMouse
@onready var chk_warp_mouse = $BaseControl/Layout/Row2/WarpMouse
@onready var lbl_file_path = $BaseControl/Layout/Row3/FilePath
@onready var play_buttons = $BaseControl/Layout/Row1/PlayButtons
@onready var tabs = $BaseControl/Layout/Row3/TabContainer
@onready var recording_list = $BaseControl/Layout/Row3/TabContainer/RecordingList
@onready var recording_details = $BaseControl/Layout/Row3/TabContainer/RecordingDetails

@onready var tree_row = $BaseControl/Layout/Row3
@onready var row_2 = $BaseControl/Layout/Row2
@onready var row_3 = $BaseControl/Layout/Row3

@onready var base_ctrl = $BaseControl

signal play
signal play_fast
signal record
signal stop
signal recorder_selected(input_recorder)
signal save
signal save_as(path)
signal load_file(path)
signal clear
signal details_changed

var _load_dlg = null
var _save_dlg = null
var _normal_size = Vector2.ZERO

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
	btn_play_fast.visible = false

	#display_normal()

	tabs.set_tab_disabled(1, true)

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
	tabs.set_tab_disabled(1, false)
	recording_details.load_data(input_recorder.recording)
	recorder_selected.emit(input_recorder)


func _on_clear_pressed() -> void:
	clear.emit()


func _on_recording_details_changed() -> void:
	details_changed.emit()

# ----------------
# Public
# ----------------
func display_normal():
	push_error("DISPLAY_NORMAL DOES NOTHING")
	pass


func display_record(recording_name = ""):
	push_error("DISPLAY_RECORD DOES NOTHING")
	pass


func display_play(recording_name = ""):
	push_error("DISPLAY_PLAY DOES NOTHING")
	pass


func get_enabled_inputs():
	return recording_details.get_enabled_inputs()
	
	
func clear_gui():
	recording_list.reset()
	recording_details.clear()
	lbl_file_path.text = ""


func show_overlay(should):
	%Overlay.visible = should


func show_recording_details():
	tabs.current_tab = 1
	

func show_recording_list():
	tabs.current_tab = 0
