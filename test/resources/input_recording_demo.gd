extends Node2D


@onready var edit_1 = $Things/Layout/TextBoxes/Edit1
@onready var edit_2 = $Things/Layout/TextBoxes/Edit2
@onready var gut_player = $"2DStuff/GutPlayer"
@onready var input_recorder = $SomeNode/InputRecorder

var _orig_gut_player_position = Vector2.ZERO

func _ready():
	_orig_gut_player_position = gut_player.position
	input_recorder.reset_method = reset_scene


func _on_reset_pressed():
	reset_scene()


func _process(_delta):
	if(gut_player.position.y > 3000):
		gut_player.velocity = Vector2.ZERO
		gut_player.position = _orig_gut_player_position


func reset_scene():
	edit_1.clear()
	edit_2.clear()
	$Things/Layout/RadioButtons/Radio1.button_pressed = true
	gut_player.position = _orig_gut_player_position
