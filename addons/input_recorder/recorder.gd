class_name IR_Recorder
extends Node

var _frame_counter := 0

var _is_recording := false
var is_recording = _is_recording :
	get: return _is_recording
	set(val): pass

var recording := IR_Recording.new()
var record_mouse := true


func _physics_process(_delta):
	if(is_recording):
		_frame_counter += 1


func _input(event):
	if(is_recording):
		if(record_mouse or !(event is InputEventMouse)):
			add(event)


# -------------
# Public
# -------------
func add(event):
	recording.add_event(_frame_counter, event)


func get_events_for_frame(frame):
	return recording.get_frame_events(frame)


func get_events_for_index(idx):
	return recording.queue[recording.queue.keys()[idx]]


func record():
	recording.clear()
	_frame_counter = 0
	_is_recording = true


func stop():
	_is_recording = false


func size():
	return recording.size()


func get_number_of_events():
	var total = 0
	for key in recording.queue:
		total += recording.queue[key].size()
	return total


func to_s():
	var to_return = "NOT DOING THIS YET"
	# for key in queue:
	# 	to_return += str("f: ", key).rpad(10, ' ')
	# 	for i in range(queue[key].size()):
	# 		if(i != 0):
	# 			to_return += " ".rpad(10)
	# 		to_return += str(queue[key][i].as_text(), "\n").replace("InputEvent", "")
	return to_return


func duration():
	return recording.get_duration()
