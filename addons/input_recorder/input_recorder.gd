extends ColorRect


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var _recorder : IR_InputRecorder = null
var _playback := IR_InputPlayer.new()
var _config_file := ConfigFile.new()
var _parent_scene = null

var reset_method : Callable = _do_nothing

@onready var btn_record = $Layout/Row1/Record
@onready var btn_stop = $Layout/Row1/Stop
@onready var btn_play = $Layout/Row1/PlayButtons/Play
@onready var btn_play_fast = $Layout/Row1/PlayButtons/PlayFast
@onready var progress = $Layout/ProgressBar
@onready var chk_record_mouse = $Layout/Row2/RecordMouse
@onready var chk_warp_mouse = $Layout/Row2/WarpMouse
@onready var event_output = $Output/Layout/TabContainer/EventOutput
@onready var tree_recordings = $Layout/Row3/ScrollContainer/Tree
@onready var tree_row = $Layout/Row3
@onready var _recorders := $Layout/Row3/ScrollContainer/Tree

## The path to save/load recordings to.  When not set, this will be the same
## path as the parent scene with "_input_recordings.cfg" appended.  This path
## is loaded on start up.  If you want to change this path at runtime, you must
## also call load_config_file() after setting it, if you want to load the file.
@export var save_path : String = ""

signal playback_done

func _save_path_from_parent_filename():
	if(get_parent() != get_tree().root):
		var saved_scene = get_parent()
		while(saved_scene.scene_file_path == ""):
			saved_scene = saved_scene.get_parent()
		var parent_file : String = saved_scene.scene_file_path.get_file()
		var ext = parent_file.get_extension()
		var save_file = saved_scene.scene_file_path.replace(parent_file, parent_file.replace(str(".", ext), "_input_recordings.cfg"))
		_parent_scene = saved_scene

		return save_file
	if(get_parent() == get_tree().root):
		return "res://recordings/input_recorder.cfg"


func _ready():
	if(save_path.get_file() == ""):
		save_path = save_path.path_join(_save_path_from_parent_filename())
		print("save path = ", save_path)
	add_child(_playback)
	_playback.done.connect(_on_playback_done)
	_update_buttons()

	_playback.warp_mouse = true
	load_config_file(save_path)

	if(_parent_scene.has_method("reset_scene")):
		reset_method = _parent_scene.reset_scene


func _process(_delta):
	if(_playback.is_playing):
		progress.value = _playback.percent_complete()


func _update_buttons():
	btn_stop.disabled = _recorder == null or !(_recorder.is_recording or _playback.is_playing)
	btn_play.disabled = !btn_stop.disabled
	btn_play_fast.disabled = btn_play.disabled
	btn_record.disabled = !btn_stop.disabled
	tree_row.visible = btn_stop.disabled


# Default for reset_method
func _do_nothing():
	pass


# -------------
# Events
# -------------
func _on_playback_done():
	progress.value = 1.0
	_update_buttons()
	btn_stop.release_focus()
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
	if(_recorder.is_recording):
		_recorder.stop()
		event_output.text = _recorder.to_s()
		event_output.text += "\n" + _recorder_totals_text()
		_recorders.populate_tree_control(save_path)
	elif(_playback.is_playing):
		_playback.stop()
	_update_buttons()
	btn_stop.release_focus()
	compact(false)


func _on_play_pressed():
	await reset_method.call()
	btn_play.release_focus()
	playback(false)


func _on_play_fast_pressed():
	await reset_method.call()
	btn_play_fast.release_focus()
	playback(true)


func _on_tree_recorder_selected(input_recorder):
	_recorder = input_recorder


func _on_save_pressed():
	save_config_file(save_path)


func _on_load_pressed():
	pass # Replace with function body.


func _on_save_as_pressed():
	pass # Replace with function body.

# -------------
# Public?
# -------------
func playback(do_it_fast):
	_playback.warp_mouse = chk_warp_mouse.button_pressed
	if(do_it_fast):
		_playback.play_input_queue_quick(_recorder)
	else:
		_playback.play_input_queue(_recorder)

	_update_buttons()
	progress.value = 0.0
	compact(true)


func record():
	await reset_method.call()
	_recorder = _recorders.new_recorder()
	add_child(_recorder)
	btn_record.release_focus()
	_recorder.record_mouse = chk_record_mouse.button_pressed
	_recorder.record()
	_update_buttons()
	compact(true)


func stop():
	pass


func load_config_file(path=save_path):
	if(FileAccess.file_exists(path)):
		_config_file.load(path)
		_recorders.load_from_config_file(_config_file)
	_recorders.populate_tree_control(save_path)


func save_config_file(path=save_path):
	_recorders.save_to_config_file(_config_file)
	_config_file.save(path)


func play_recording(recording_name):
	var to_play = _recorders.input_recorders.get(recording_name, null)
	if(to_play != null):
		_recorder = to_play
		playback(false)
		return to_play.duration()
	return 0


var _last_size = size
func compact(should):
	if(should):
		_last_size = size
		size = custom_minimum_size
	else:
		size = _last_size

	btn_stop.visible = true
	btn_play.visible = !should
	btn_play_fast.visible = !should
	btn_record.visible = !should
	tree_row.visible = !should

