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
var _mouse_draw = null

## When set, changes to the list of recordings (add, delete, rename) will be
## automatically saved.  When false, there is a save button you have to press
## to save changes.
## [br][br]
## When autosave is disabled, quitting will lose all changes since last save.
@export var autosave : bool = true

## Draw mouse crosshair while recording.  This is an approximation of the mouse
## mouse position and not necessarily where the mouse is in the recording.
@export var draw_mouse_when_recording : bool = false

## Draw mouse crosshair when playing a recording.  This will render all mouse
## events that were recorded.
@export var draw_mouse_when_playing : bool = true

## A method that resets the scene the recorder is in.  This will be called
## before recording and playback to make sure the scene is in the same state
## everytime.  Awaits are supported.
var reset_method : Callable = func(): pass

## The path to save/load recordings to.  When not set, this will be the same
## path as the parent scene with "_input_recordings.cfg" appended.  This path
## is loaded on start up.  If you want to change this path at runtime, you must
## also call load_config_file() after setting it, if you want to load the file.
## [br][br]
## [b]NOTE:[/b]  The parent scene is the first parent node that has a
## [member Node.scene_file_path].  This might too [i]smart[/i] for its own good.
## Lemme know.
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

	add_child(_playback)
	_playback.done.connect(_on_playback_done)

	if(!Engine.is_editor_hint()):
		_ready_runtime()


func _ready_runtime():
	_mouse_draw = load("res://addons/input_recorder/mouse_draw.gd").new()
	add_child(_mouse_draw)

	_recorders = _controls.recording_list

	_controls.play.connect(_on_play_pressed)
	_controls.record.connect(_on_record_pressed)
	_controls.stop.connect(_on_stop_pressed)
	_controls.play_fast.connect(_on_play_fast_pressed)
	_controls.recorder_selected.connect(_on_list_recorder_selected)
	_controls.save.connect(_on_save_pressed)
	_controls.save_as.connect(_on_save_as)
	_controls.load_file.connect(_on_load_file)
	_controls.recording_list.changed.connect(_on_list_changed)

	_controls.btn_save.visible = !autosave

	_parent_scene = get_parent()
	while(_parent_scene.scene_file_path == ""):
		_parent_scene = _parent_scene.get_parent()

	if(save_path.get_file() == ""):
		save_path = save_path.path_join(_save_path_from_parent_filename())

	_playback.warp_mouse = true
	_playback.mouse_draw = _mouse_draw
	load_config_file(save_path)

	_update_buttons()


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


func _is_idle():
	return _recorder == null or !(_recorder.is_recording or _playback.is_playing)


func _is_doing_something():
	return !_is_idle()


func _update_buttons():
	# _controls.btn_stop.disabled = _is_idle()
	_controls.btn_play.disabled = !_recorders.has_selected() or _is_doing_something()
	#_controls.btn_play_fast.disabled = _controls.btn_play.disabled
	# _controls.btn_record.disabled = !_controls.btn_stop.disabled
	# _controls.tree_row.visible = _controls.btn_stop.disabled


func _autosave():
	if(autosave):
		save_config_file(save_path)


func _recorder_totals_text():
	return str(
		"Number of events     ", _recorder.get_number_of_events(), "\n",
		"Frames with events:  ", _recorder.size(), "\n",
		"Duration             ", _recorder.duration(), " frames")

# -------------
# Events
# -------------
func _on_resized():
	_controls.size = size


func _on_playback_done():
	_mouse_draw.disabled = true
	_controls.progress.value = 1.0
	_update_buttons()
	_controls.btn_stop.release_focus()
	playback_done.emit()
	_controls.display_normal()


func _on_record_pressed():
	record()


func _on_stop_pressed():
	stop()


func _on_play_pressed():
	await reset_method.call()
	_controls.btn_play.release_focus()
	play_current()


func _on_play_fast_pressed():
	await reset_method.call()
	_controls.btn_play_fast.release_focus()
	play_current()


func _on_list_recorder_selected(input_recorder):
	_recorder = input_recorder
	_update_buttons()


func _on_list_changed():
	_autosave()
	_update_buttons()


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
## Play the currently selected recording.
func play_current(rec_name=""):
	if(_recorder == null):
		return

	if(draw_mouse_when_playing):
		_mouse_draw.disabled = false

	_playback.warp_mouse = _controls.chk_warp_mouse.button_pressed
	_playback.play_input_queue(_recorder)

	_update_buttons()
	_controls.progress.value = 0.0
	if(rec_name == ""):
		_controls.display_play(_recorders.get_selected_name())
	else:
		_controls.display_play(rec_name)


## Start a new recording.  This will be added to the list when recording
## finishes
func record():
	await reset_method.call()
	if(draw_mouse_when_recording):
		_mouse_draw.disabled = false
		_mouse_draw.live_draw = true
	_recorder = _recorders.new_recorder()
	add_child(_recorder)
	_controls.btn_record.release_focus()
	_recorder.record_mouse = _controls.chk_record_mouse.button_pressed
	_recorder.record()
	_update_buttons()
	_controls.display_record()


## Stop playing or recording, whichever is occurring.
func stop():
	if(_recorder.is_recording):
		_recorder.stop()
		# _controls.event_output.text = _recorder.to_s()
		# _controls.event_output.text += "\n" + _recorder_totals_text()
		_controls.recording_list.refresh()
		_autosave()
	elif(_playback.is_playing):
		_playback.stop()

	_controls.display_normal()
	_mouse_draw.disabled = true
	_mouse_draw.live_draw = false
	_controls.btn_stop.release_focus()
	_update_buttons()


## Defaults to the value in save_path.  This loads a config file at the specified path.  This does
## not set save_path when passed a value.
func load_config_file(path:=save_path):
	if(FileAccess.file_exists(path)):
		_config_file.clear()
		_config_file.load(path)
		_recorders.load_from_config_file(_config_file)
		_controls.lbl_file_path.text = path.get_file()
		_controls.lbl_file_path.tooltip_text = path


## Defaults to the value in save_path.  Saves all recordings to a config file at the specified path.
## This does not set save_path when passed a value.
func save_config_file(path:=save_path):
	_config_file.clear()
	_recorders.save_to_config_file(_config_file)
	_config_file.save(path)
	_controls.lbl_file_path.text = path.get_file()


## Plays the recording with the passed in name.  The duration in frames is
## returned.  If the recording is not found, zero is returned.
func play_recording(recording_name):
	var to_play = _recorders.input_recorders.get(recording_name, null)
	_controls.lbl_recording_name.text = recording_name
	if(to_play != null):
		_recorder = to_play
		play_current(recording_name)
		return to_play.duration()
	return 0


## Returns the amount of time the playback of the current recording will take
## based on the number of frames in the recording and
## [member Engine.physics_ticks_per_second].  If there is no selected/active
## recording then zero is returned.
func get_playback_time():
	if(_recorder == null):
		return 0.0
	return float(_recorder.duration()) / float(Engine.physics_ticks_per_second)
