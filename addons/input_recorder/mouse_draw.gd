extends Node2D

var _draw_at = Vector2(0, 0)
var _b1_down = false
var _b2_down = false


var down_color = Color(1, 1, 1, .25)
var up_color = Color(0, 0, 0, .25)
var line_color = Color(1, 0, 0)
var disabled = true :
	get : return disabled
	set(val) :
		disabled = val
		queue_redraw()
var live_draw = false :
	get : return live_draw
	set(val):
		live_draw = val
		queue_redraw()


func _input(event: InputEvent) -> void:
	if(live_draw):
		draw_event(event)


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
