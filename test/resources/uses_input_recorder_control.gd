extends Node2D

func _ready():
	$InputRecorder.reset_method = reset_scene

func reset_scene():
	$Things/Layout/TextBoxes/Edit1.text = ""
	$Things/Layout/TextBoxes/Edit2.text = ""
