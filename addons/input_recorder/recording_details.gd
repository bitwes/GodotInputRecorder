extends Control


class DetailEntry:
	extends HBoxContainer
	
	var frame : int = 0
	var inputs = []
	
	var frame_label : Label
	var input_label : Label
	var count_label : Label
	var include_chk : CheckBox
	var bg_color = Color(1, 1, 1, 0)
	
	func _init() -> void:
		size_flags_horizontal = SIZE_EXPAND_FILL
	
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), bg_color)
	
	func _ready():
		include_chk = CheckBox.new()
		include_chk.button_pressed = true
		add_child(include_chk)

		frame_label = Label.new()
		frame_label.custom_minimum_size.x = 60
		add_child(frame_label)
		
		count_label = Label.new()
		count_label.custom_minimum_size.x = 40
		add_child(count_label)

		input_label = Label.new()
		input_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(input_label)
		
		_update_frame_label()
		_update_input_label()
	
			
	func _update_frame_label():
		frame_label.text = str(frame)
		
		
	func _update_input_label():
		if(inputs.size() > 1):
			count_label.text = str(inputs.size())
		
		var txt = ""
		var first = true
		for input in inputs:
			if(!first):
				txt += " + "
			else:
				first = false
			txt += input.as_text()
		input_label.text = txt




@onready var items = $Layout/ScrollContainer/Items
var _recording : IR_Recording


func _ready():	
	if(get_parent() == get_tree().root):
		_debug_ready()
	_add_header()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 1, .25))


func _debug_ready():
	var cf = ConfigFile.new()
	cf.load("res://test/resources/input_recording_demo_input_recordings.cfg")
	var recording := IR_Recording.new()
	recording.load_config_file_section(cf, "Do A Thing")
	load_data(recording)


func _add_header():
	var header_entry = DetailEntry.new()
	
	$Layout.add_child(header_entry)
	$Layout.move_child(header_entry, 0)
	header_entry.bg_color = Color(0, 0, 0, .5)
	header_entry.frame_label.text = "Frame"
	header_entry.count_label.text = "#"
	header_entry.input_label.text = "Inputs"
	header_entry.include_chk.toggled.connect(func(val):
		check_all(val))


func _on_chk_toggled(new_state, frame_index):
	_recording.disable_frame(frame_index, new_state)


func check_all(should):
	for item in items.get_children():
		item.include_chk.button_pressed = should
		

func load_data(recording_data : IR_Recording):
	_recording = recording_data
	clear()
	for key in recording_data.queue:
		var e = DetailEntry.new()
		e.frame = key
		e.inputs = recording_data.get_frame_events(key)
		items.add_child(e)
		e.include_chk.button_pressed = !recording_data.queue[key].disabled
		e.include_chk.toggled.connect(_on_chk_toggled.bind(key))


func clear():
	for child in items.get_children():
		child.queue_free()


func get_enabled_inputs():
	var to_return = {}
	for child in items.get_children():
		if(child.include_chk):
			to_return[child.frame] = child.inputs
	return to_return
	
	
func get_all_inputs():
	var to_return = {}
	for child in items.get_children():
		to_return[child.frame] = child.inputs
	return to_return
	
