class_name IR_Player
extends Node

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class MouseDraw:
	extends Node2D

	var down_color = Color(1, 1, 1, .25)
	var up_color = Color(0, 0, 0, .25)
	var line_color = Color(1, 0, 0)
	var disabled = true :
		get : return disabled
		set(val) :
			disabled = val
			queue_redraw()

	var _draw_at = Vector2(0, 0)
	var _b1_down = false
	var _b2_down = false


	func draw_event(event):
		if(event is InputEventMouse):
			_draw_at = event.position
			if(event is InputEventMouseButton):
				if(event.button_index == MOUSE_BUTTON_LEFT):
					_b1_down = event.pressed
				elif(event.button_index == MOUSE_BUTTON_RIGHT):
					_b2_down = event.pressed
		queue_redraw()


	func _draw_cicled_cursor():
		var r = 10
		var b1_color = up_color
		var b2_color = up_color

		if(_b1_down):
			var pos = _draw_at - (Vector2(r * 1.5, 0))
			draw_arc(pos, r / 2, 0, 360, 180, b1_color)

		if(_b2_down):
			var pos = _draw_at + (Vector2(r * 1.5, 0))
			draw_arc(pos, r / 2, 0, 360, 180, b2_color)

		draw_arc(_draw_at, r, 0, 360, 360, line_color, 1)
		draw_line(_draw_at - Vector2(0, r), _draw_at + Vector2(0, r), line_color)
		draw_line(_draw_at - Vector2(r, 0), _draw_at + Vector2(r, 0), line_color)


	func _draw_square_cursor():
		var r = 10
		var b1_color = up_color
		var b2_color = up_color

		if(_b1_down):
			b1_color = down_color

		if(_b2_down):
			b2_color = down_color

		var blen = r * .75
		# left button rectangle
		draw_rect(Rect2(_draw_at - Vector2(blen, blen), Vector2(blen, blen * 2)), b1_color)
		# right button rectrangle
		draw_rect(Rect2(_draw_at - Vector2(0, blen), Vector2(blen, blen * 2)), b2_color)
		# Crosshair
		draw_line(_draw_at - Vector2(0, r), _draw_at + Vector2(0, r), line_color)
		draw_line(_draw_at - Vector2(r, 0), _draw_at + Vector2(r, 0), line_color)


	func _draw():
		if(disabled):
			return
		_draw_square_cursor()




# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
var _frame_counter = 0
var _is_playing = false
var _queue = null
var _num_played = 0
var _key_index = 0
var _ff = false
var _mouse_draw = null

var warp_mouse := true
var is_playing = _is_playing :
	get: return _is_playing
	set(val): pass

signal done

func _ready():
	_mouse_draw = MouseDraw.new()
	add_child(_mouse_draw)
	_mouse_draw.disabled = true


func _physics_process(_delta):
	if(_is_playing):
		if(_ff):
			_play_next()
		else:
			_play_real_time()
		_frame_counter += 1
	else:
		if(!_mouse_draw.disabled):
			_mouse_draw.disabled = true


func _play_events(events):
	for original in events:
		var event = original.duplicate()
		if(event is InputEventMouse):
			var xform = get_viewport().get_screen_transform()
			event.position = xform.get_scale() * event.position + xform.get_origin()
			
		_mouse_draw.draw_event(original)
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
	_mouse_draw.disabled = false
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
