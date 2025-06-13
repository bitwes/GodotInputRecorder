extends Control

var input_recorders = {}
var default_name = 'Recording '
var RecordingListEntry = load('res://addons/input_recorder/recording_entry.tscn')
var select_button_group = ButtonGroup.new()

@onready var _entry_control = $Entry
@onready var _the_list = $Scroller/TheList
@onready var _dlg_delete = $DeleteDialog

signal recorder_selected(input_recorder)
signal recorder_activated(input_recorder)
signal changed

func _notification(what):
	if(what == NOTIFICATION_PREDELETE):
		for key in input_recorders:
			if(is_instance_valid(input_recorders[key])):
				input_recorders[key].queue_free()


func _ready():
	_entry_control.visible = false
	_dlg_delete.add_cancel_button("Cancel")


func _new_entry(display_name):
	var new_ctrl = RecordingListEntry.instantiate()
	new_ctrl.select_button_group = select_button_group
	_the_list.add_child(new_ctrl)

	new_ctrl.recording_name = display_name
	new_ctrl.rename_callback = _can_change_name_of_entry
	# new_ctrl.ctrl_details.load_data(input_recorders[display_name].queue)

	new_ctrl.rename.connect(_on_entry_renamed)
	new_ctrl.delete.connect(_on_entry_deleted)
	new_ctrl.selected.connect(_on_entry_selected)
	new_ctrl.play.connect(_on_entry_play)

	return new_ctrl


func _can_change_name_of_entry(old_name, new_name):
	return !input_recorders.has(new_name)


func _clear_list_entries():
	for child in _the_list.get_children():
		_the_list.remove_child(child)
		child.queue_free()

# ------------------
# Events
# ------------------
func _on_entry_renamed(old_name, new_name):
	input_recorders[new_name] = input_recorders[old_name]
	input_recorders.erase(old_name)
	changed.emit()


var _to_delete = '__not_set__'
func _on_entry_deleted(recording_name):
	_to_delete = recording_name
	_dlg_delete.popup_centered(Vector2(200, 100))


func _on_delete_dialog_confirmed():
	delete_recording(_to_delete)
	_to_delete = '__not_set__'
	changed.emit()


func _on_entry_selected(recording_name):
	recorder_selected.emit(input_recorders[recording_name])


func _on_entry_play(recording_name):
	recorder_activated.emit(input_recorders[recording_name])


# ------------------
# Public
# ------------------
func new_recorder():
	var r = IR_Recorder.new()
	var counter = input_recorders.size() + 1
	var key = str(default_name, counter)
	while(input_recorders.has(key)):
		counter += 1
		key = str(default_name, counter)
	input_recorders[key] = r
	var entry = _new_entry(key)
	entry.btn_select.button_pressed = true
	return r


func save_to_config_file(config_file: ConfigFile):
	for key in input_recorders:
		input_recorders[key].recording.save_config_file_section(config_file, key)
		# config_file.set_value(key, "recordings", input_recorders[key].queue)


func load_from_config_file(config_file : ConfigFile):
	reset()
	for section in config_file.get_sections():
		var recorder = IR_Recorder.new()
		recorder.recording.load_config_file_section(config_file, section)
		# recorder.queue = config_file.get_value(section, "recordings")
		input_recorders[section] = recorder
	refresh()


func refresh():
	_clear_list_entries()
	for key in input_recorders:
		_new_entry(key)


func reset():
	for key in input_recorders:
		if(is_instance_valid(input_recorders[key])):
			input_recorders[key].queue_free()
	input_recorders.clear()
	_clear_list_entries()


func delete_recording(recording_name):
	input_recorders.erase(recording_name)
	refresh()


func has_selected():
	var to_return = select_button_group.get_pressed_button()
	if(to_return != null and !to_return.is_inside_tree()):
		to_return = null

	return to_return != null


func get_selected_name():
	if(has_selected()):
		return select_button_group.get_pressed_button().text
	else:
		return ""
