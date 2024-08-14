@tool
extends Control
class_name IR_InputRecorderControl
## This is the control for recording input

var _ControlsScene = load('res://addons/input_recorder/input_recorder_controls.tscn')
var _controls = null
var _recorders = null

var _recorder : IR_Recorder = null
var _playback := IR_Player.new()
var _config_file := ConfigFile.new()
var _parent_scene = null

## A method that resets the scene the recorder is in.  This will be called
## before recording and playback to make sure the scene is in the same state
## everytime.
var reset_method : Callable = _do_nothing

## The path to save/load recordings to.  When not set, this will be the same
## path as the parent scene with "_input_recordings.cfg" appended.  This path
## is loaded on start up.  If you want to change this path at runtime, you must
## also call load_config_file() after setting it, if you want to load the file.
@export var save_path : String = ""

## Emitted when playing a recording has finished.
signal playback_done


func _ready():
	_controls = _ControlsScene.instantiate()
	add_child(_controls)
	custom_minimum_size = _controls.custom_minimum_size
	_controls.anchors_preset = PRESET_FULL_RECT
	_controls.size = size

	resized.connect(_on_resized)
	save_path = save_path
	_recorders = _controls.recording_list

	add_child(_playback)
	_playback.done.connect(_on_playback_done)

	if(!Engine.is_editor_hint()):
		_ready_runtime()


func _ready_runtime():
	_controls.play.connect(_on_play_pressed)
	_controls.record.connect(_on_record_pressed)
	_controls.stop.connect(_on_stop_pressed)
	_controls.play_fast.connect(_on_play_fast_pressed)
	_controls.recorder_selected.connect(_on_tree_recorder_selected)
	_controls.save.connect(_on_save_pressed)
	_controls.save_as.connect(_on_save_as)
	_controls.load_file.connect(_on_load_file)

	_parent_scene = get_parent()
	while(_parent_scene.scene_file_path == ""):
		print(_parent_scene)
		_parent_scene = _parent_scene.get_parent()
	print(_parent_scene)

	if(save_path.get_file() == ""):
		save_path = save_path.path_join(_save_path_from_parent_filename())
		print("save path = ", save_path)

	_update_buttons()

	_playback.warp_mouse = true
	load_config_file(save_path)

	if(_parent_scene.has_method("reset_scene")):
		reset_method = _parent_scene.reset_scene


func _save_path_from_parent_filename():
	if(_parent_scene != get_tree().root):
		var parent_file : String = _parent_scene.scene_file_path.get_file()
		var ext = parent_file.get_extension()
		var save_file = _parent_scene.scene_file_path.replace(parent_file, parent_file.replace(str(".", ext), "_input_recordings.cfg"))
		return save_file
	if(_parent_scene == get_tree().root):
		return "res://recordings/input_recorder.cfg"


func _process(_delta):
	if(_playback.is_playing):
		_controls.progress.value = _playback.percent_complete()


func _update_buttons():
	_controls.btn_stop.disabled = _recorder == null or !(_recorder.is_recording or _playback.is_playing)
	_controls.btn_play.disabled = !_controls.btn_stop.disabled
	_controls.btn_play_fast.disabled = _controls.btn_play.disabled
	_controls.btn_record.disabled = !_controls.btn_stop.disabled
	_controls.tree_row.visible = _controls.btn_stop.disabled


# Default for reset_method
func _do_nothing():
	pass


# -------------
# Events
# -------------
func _on_resized():
	_controls.size = size


func _on_playback_done():
	_controls.progress.value = 1.0
	_update_buttons()
	_controls.btn_stop.release_focus()
	playback_done.emit()
	compact(false)


func _on_record_pressed():
	record()


func _recorder_totals_text():
	return str(
		"Number of events     ", _recorder.get_number_of_events(), "\n",
		"Frames with events:  ", _recorder.size(), "\n",
		"Duration             ", _recorder.duration(), " frames")


func _on_stop_pressed():
	stop()


func _on_play_pressed():
	await reset_method.call()
	_controls.btn_play.release_focus()
	playback(false)


func _on_play_fast_pressed():
	await reset_method.call()
	_controls.btn_play_fast.release_focus()
	playback(true)


func _on_tree_recorder_selected(input_recorder):
	_recorder = input_recorder


func _on_save_pressed():
	save_config_file(save_path)


func _on_load_file(path):
	load_config_file(path)
	save_path = path


func _on_save_as(path):
	save_config_file(path)
	save_path = path


# -------------
# Public
# -------------
func playback(do_it_fast):
	if(_recorder == null):
		return
		
	_playback.warp_mouse = _controls.chk_warp_mouse.button_pressed
	if(do_it_fast):
		_playback.play_input_queue_quick(_recorder)
	else:
		_playback.play_input_queue(_recorder)

	_update_buttons()
	_controls.progress.value = 0.0
	compact(true)


## Start a new recording
func record():
	await reset_method.call()
	_recorder = _recorders.new_recorder()
	add_child(_recorder)
	_controls.btn_record.release_focus()
	_recorder.record_mouse = _controls.chk_record_mouse.button_pressed
	_recorder.record()
	_update_buttons()
	compact(true)


## Stop playing or recording, whichever is occurring.
func stop():
	if(_recorder.is_recording):
		_recorder.stop()
		_controls.event_output.text = _recorder.to_s()
		_controls.event_output.text += "\n" + _recorder_totals_text()
		_controls.recording_list.refresh()
	elif(_playback.is_playing):
		_playback.stop()

	_update_buttons()
	_controls.btn_stop.release_focus()
	compact(false)


## Loads the config file at the specified path
func load_config_file(path=save_path):
	if(FileAccess.file_exists(path)):
		_config_file.clear()
		_config_file.load(path)
		_recorders.load_from_config_file(_config_file)
		_controls.lbl_file_path.text = path.get_file()
		_controls.lbl_file_path.tooltip_text = path


## Saves all recordings to a config file at the specified path
func save_config_file(path=save_path):
	_config_file.clear()
	_recorders.save_to_config_file(_config_file)
	_config_file.save(path)
	_controls.lbl_file_path.text = path.get_file()


## Plays the recording with the passed in name.
func play_recording(recording_name):
	var to_play = _recorders.input_recorders.get(recording_name, null)
	if(to_play != null):
		_recorder = to_play
		playback(false)
		return to_play.duration()
	return 0


## Returns the amount of time the playback will take based on the number of
## frames in the recording and Engine.physics_ticks_per_second
func get_playback_time():
	return float(_recorder.duration()) / float(Engine.physics_ticks_per_second)


var _last_size = size
## Changes the display of the InputRecorder control to compact mode, or
## normal mode if you pass false.
func compact(should):
	if(should):
		_last_size = size
		size = custom_minimum_size
	else:
		size = _last_size

	_controls.btn_stop.visible = true
	_controls.btn_play.visible = !should
	#_controls.btn_play_fast.visible = !should
	_controls.btn_record.visible = !should
	_controls.tree_row.visible = !should
