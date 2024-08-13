class_name IR_InputPlayer
extends Node


var _frame_counter = 0
var _is_playing = false
var _queue = null
var _num_played = 0
var _key_index = 0
var _ff = false

var warp_mouse := true
var is_playing = _is_playing :
    get: return _is_playing
    set(val): pass

signal done

func _physics_process(_delta):
    if(_is_playing):
        if(_ff):
            _play_next()
        else:
            _play_real_time()
        _frame_counter += 1


func _play_events(events):
    for event in events:
        Input.parse_input_event(event)
        if(warp_mouse and event is InputEventMouse):
            DisplayServer.warp_mouse(event.position)


func _play_next():
    var events = _queue.get_events_for_index(_key_index)
    _play_events(events)

    _key_index += 1
    if(_key_index >= _queue.size()):
        _is_playing = false
        done.emit()


func _play_real_time():
    var events = _queue.get_events_for_frame(_frame_counter)
    _play_events(events)

    if(events.size() > 0):
        _num_played += 1
        if(_num_played == _queue.size()):
            _is_playing = false
            done.emit()


func _play_queue(iq):
    _key_index = 0
    _frame_counter = 0
    _num_played = 0
    _is_playing = true
    _queue = iq


# -------------
# Public
# -------------
func play_input_queue(iq):
    _ff = false
    _play_queue(iq)


func play_input_queue_quick(iq):
    _ff = true
    _play_queue(iq)


func stop():
    _is_playing = false


func percent_complete():
    if(_ff):
        return float(_key_index) / float(_queue.size() -1)
    else:
        return float(_frame_counter) / float(_queue.duration())


