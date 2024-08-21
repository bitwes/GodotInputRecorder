extends Node2D


@onready var edit_1 = $Things/Layout/TextBoxes/Edit1
@onready var edit_2 = $Things/Layout/TextBoxes/Edit2
@onready var the_character = $"2DStuff/GutPlayer"
@onready var input_recorder = $SomeNode/InputRecorder

var _orig_char_position = Vector2.ZERO

func _ready():
	_orig_char_position = the_character.position
	input_recorder.reset_method = reset_scene


func _on_reset_pressed():
	reset_scene()


func _process(_delta):
	if(the_character.position.y > 3000):
		the_character.velocity = Vector2.ZERO
		the_character.position = _orig_char_position


func reset_scene():
	edit_1.clear()
	edit_2.clear()
	$Things/Layout/RadioButtons/Radio1.button_pressed = true
	the_character.position = _orig_char_position
