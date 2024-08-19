extends Node2D

@onready var _list = $ColorRect/RecordingList


func _ready():
	for i in range(20):
		_list.new_recorder()
