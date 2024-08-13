extends Tree

var input_recorders = {}
var recording_name = 'Recording '
var num_recordings = 0

signal recorder_selected(input_recorder)


func _tree_item_for_recorder(key, recorder):
	var item = create_item(get_root())
	item.set_text(0, key)
	item.set_text(1, str(recorder.duration(), 'f: ', recorder.get_number_of_events()))
	return item

func _notification(what):
	if(what == NOTIFICATION_PREDELETE):
		for key in input_recorders:
			input_recorders[key].queue_free()

# -----------
# Events
# -----------
func _on_item_selected():
	var selected = get_selected()
	if(selected != null and selected != get_root()):
		var rec_name = selected.get_text(0)
		recorder_selected.emit(input_recorders[rec_name])


# -----------
# Public
# -----------
func new_recorder():
	var r = IR_InputRecorder.new()
	num_recordings += 1
	var key = str(recording_name, num_recordings)
	input_recorders[key] = r
	var item = _tree_item_for_recorder(key, r)
	item.select(0)
	return r


func save_to_config_file(config_file: ConfigFile):
	config_file.clear()
	for key in input_recorders:
		config_file.set_value(key, "recordings", input_recorders[key]._queue)


func load_from_config_file(config_file : ConfigFile):
	input_recorders.clear()
	for section in config_file.get_sections():
		num_recordings += 1
		var recorder = IR_InputRecorder.new()
		recorder._queue = config_file.get_value(section, "recordings")
		input_recorders[section] = recorder


func populate_tree_control(path):
	clear()
	var root_item = create_item()
	root_item.set_text(0, path)
	root_item.set_selectable(0, false)
	for key in input_recorders:
		_tree_item_for_recorder(key, input_recorders[key])

