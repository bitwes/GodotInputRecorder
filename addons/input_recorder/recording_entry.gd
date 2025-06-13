extends Control

signal delete(rec_name)
signal rename(old_name, new_name)
signal selected(rec_name)
signal play(rec_name)

@onready var txt_name = $Rec/Name
@onready var btn_edit = $Rec/Edit
@onready var btn_delete = $Rec/Delete
@onready var btn_select = $Rec/SelectButton
@onready var ctrl_details = $RecordingDetails

var recording_name = '__not set__' :
	set(val):
		btn_select.text = val
		txt_name.text = val
		recording_name = val

var rename_callback : Callable
var select_button_group = ButtonGroup.new()

func _ready():
	txt_name.text = 'Default Text'
	txt_name.text_submitted.connect(_on_name_submitted)
	btn_edit.toggled.connect(_on_edit_toggled)
	btn_delete.pressed.connect(_on_delete_pressed)
	btn_select.toggled.connect(_on_select_toggled)
	btn_select.gui_input.connect(_on_select_button_gui_event)			
	btn_select.button_group = select_button_group
	
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
func _on_select_button_gui_event(event):
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
			btn_select.button_pressed = true
			play.emit(recording_name)
	elif(event is InputEventKey and !event.pressed):
		if(event.keycode == KEY_ENTER):
			btn_select.button_pressed = true
			selected.emit(recording_name)
			play.emit(recording_name)

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
