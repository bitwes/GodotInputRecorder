extends Control

class RecordingListEntry:
	extends Control

	signal delete(rec_name)
	signal rename(old_name, new_name)
	signal selected(rec_name)
	signal play(rec_name)

	@onready var txt_name = $Name
	@onready var btn_edit = $Edit
	@onready var btn_delete = $Delete
	@onready var btn_select = $SelectButton

	var recording_name = '__not set__' :
		set(val):
			btn_select.text = val
			txt_name.text = val
			recording_name = val

	var rename_callback : Callable

	func _ready():
		txt_name.text = 'Default Text'
		txt_name.text_submitted.connect(_on_name_submitted)
		btn_edit.toggled.connect(_on_edit_toggled)
		btn_delete.pressed.connect(_on_delete_pressed)
		btn_select.toggled.connect(_on_select_toggled)
		btn_select.gui_input.connect(func(event):
			if(event is InputEventMouseButton):
				if(event.double_click and event.button_index == MOUSE_BUTTON_LEFT):
					play.emit(recording_name))
		_edit_buttons(false)

	func _edit_buttons(editable):
		txt_name.editable = editable
		txt_name.visible = editable
		btn_delete.disabled = !editable
		btn_delete.visible = editable
		btn_select.visible = !editable
		btn_edit.button_pressed = editable

	func _start_edit():
		_edit_buttons(true)
		txt_name.grab_focus()
		


	func _end_edit():
		_edit_buttons(false)

		if(recording_name != txt_name.text):
			if(rename_callback):
				var result = rename_callback.call(recording_name, txt_name.text)
				if(result):
					rename.emit(recording_name, txt_name.text)
					recording_name = txt_name.text

	# --------------
	# Events
	# --------------
	func _on_edit_toggled(toggled_on):
		if(toggled_on):
			_start_edit()
		else:
			_end_edit()


	func _on_name_submitted(_new_text):
		_end_edit()


	func _on_delete_pressed():
		delete.emit(recording_name)

	func _on_select_toggled(toggled_on):
		if(toggled_on):
			selected.emit(recording_name)


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var input_recorders = {}
var recording_name = 'Recording '

@onready var _entry_control = $Entry
@onready var _the_list = $Scroller/TheList

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


func _new_entry(display_name):
	var new_ctrl = _entry_control.duplicate()
	new_ctrl.visible = true
	new_ctrl.set_script(RecordingListEntry)
	_the_list.add_child(new_ctrl)
	new_ctrl.recording_name = display_name
	new_ctrl.rename_callback = _can_change_name_of_entry

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


func _on_entry_deleted(recording_name):
	input_recorders.erase(recording_name)
	refresh()
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
	var key = str(recording_name, counter)
	while(input_recorders.has(key)):
		counter += 1
		key = str(recording_name, counter)
	input_recorders[key] = r
	_new_entry(key)
	return r


func save_to_config_file(config_file: ConfigFile):
	for key in input_recorders:
		config_file.set_value(key, "recordings", input_recorders[key].queue)


func load_from_config_file(config_file : ConfigFile):
	reset()
	for section in config_file.get_sections():
		var recorder = IR_Recorder.new()
		recorder.queue = config_file.get_value(section, "recordings")
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

