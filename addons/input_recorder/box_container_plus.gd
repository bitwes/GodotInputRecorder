@tool
extends BoxContainer
@export var color = Color.WHITE :
	set(val):
		color = val
		queue_redraw()


func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), color)
