class_name IR_Recorder
extends Node

var _frame_counter := 0

## Arrays of InputEvent*, keyed by frame number.  Only frames with
## input exist.
var queue := {}

var _is_recording := false
var is_recording = _is_recording :
	get: return _is_recording
	set(val): pass

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
	if(queue.has(_frame_counter)):
		queue[_frame_counter].append(event)
	else:
		queue[_frame_counter] = [event]


func get_events_for_frame(frame):
	return queue.get(frame, [])


func get_events_for_index(idx):
	return queue[queue.keys()[idx]]


func record():
	queue.clear()
	_frame_counter = 0
	_is_recording = true


func stop():
	_is_recording = false


func size():
	return queue.size()


func get_number_of_events():
	var total = 0
	for key in queue:
		total += queue[key].size()
	return total


func to_s():
	var to_return = ""
	for key in queue:
		to_return += str("f: ", key).rpad(10, ' ')
		for i in range(queue[key].size()):
			if(i != 0):
				to_return += " ".rpad(10)
			to_return += str(queue[key][i].as_text(), "\n").replace("InputEvent", "")
	return to_return


func duration():
	var to_return = 0
	if(queue.size() > 0):
		to_return =  queue.keys()[-1] - queue.keys()[0]
	return to_return

