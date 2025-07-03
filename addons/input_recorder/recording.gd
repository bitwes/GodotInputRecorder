class_name IR_Recording extends Object

# {
#   99:{
#           disabled:false,
#           events:[]
#    }
# }
var queue = {}


func load_config_file_section(config_file : ConfigFile, section : String):
	var data = config_file.get_value(section, "recordings", "___NO_VALUE___")
	if(typeof(data) == TYPE_DICTIONARY):
		for key in data:
			queue[key] = {
				"disabled":false,
				"events":data[key]
			}
	else:
		data = config_file.get_value(section, "input_recording", "___NO_VALUE___")
		if(typeof(data) == TYPE_DICTIONARY):
			queue = data


func save_config_file_section(config_file : ConfigFile, section : String):
	config_file.set_value(section, "input_recording", queue)


func get_frame_events(frame_index : int):
	var entry = queue.get(frame_index, {"events":[]})
	return entry.events


func get_index_events(key_index):
	return queue[queue.keys()[key_index]]


func get_enabled_frame_events(frame_index : int):
	var entry = queue.get(frame_index, {"disabled":false, "events":[]})
	if(entry.disabled):
		return []
	else:
		return entry.events


func get_full_frame_entry(frame_index : int):
	return queue.get(frame_index, {"disabled":false, "events":[]})


func disable_frame(frame_index : int, should : bool):
	if(queue.has(frame_index)):
		queue[frame_index].disabled = should


func is_frame_disabled(frame_index):
	if(queue.has(frame_index)):
		return queue[frame_index].disabled
	else:
		return null


func add_event(frame_index : int, event : InputEvent):
	if(queue.has(frame_index)):
		queue[frame_index].events.append(event)
	else:
		queue[frame_index] = {
			"disabled":false,
			"events":[event]
		}


func size():
	return queue.size()


func get_duration():
	var to_return = 0
	if(queue.size() > 0):
		to_return =  queue.keys()[-1]
	return to_return


func clear():
	queue.clear()


func duplicate():
	var to_return = IR_Recording.new()

	for key in queue:
		var entry = queue[key]
		var new_entry = {
			disabled = entry.disabled,
			events = []
		}
		for event in entry.events:
			new_entry.events.append(event.duplicate(true))

		to_return.queue[key] = new_entry

	return to_return


func ltrim(adjust_frames=false):
	var key_idx = 0
	var done = false
	var qkeys = queue.keys()

	var start_key = qkeys[0]
	var end_key = start_key

	while key_idx < qkeys.size() and !done:
		var key = qkeys[key_idx]
		var entry = queue[key]
		if(entry.disabled):
			queue.erase(key)
			key_idx += 1
		else:
			done = true
			end_key = key

	if(adjust_frames):
		var new_queue = {}
		qkeys = queue.keys()
		for key in qkeys:
			new_queue[key - (end_key - start_key)] = queue[key]

		queue = new_queue


func rtrim():
	var done = false
	var qkeys = queue.keys()
	var key_idx = qkeys.size() -1

	while key_idx >= 0 and !done:
		var key = qkeys[key_idx]
		var entry = queue[key]
		if(entry.disabled):
			queue.erase(key)
			key_idx -= 1
		else:
			done = true


func trim(adjust_frames=false):
	ltrim(adjust_frames)
	rtrim()