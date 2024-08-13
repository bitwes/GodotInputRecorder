@tool
extends Control

var scene = load('res://addons/input_recorder/input_recorder.tscn')
var inst = null

## The path to save/load recordings to.  When not set, this will be the same
## path as the parent scene with "_input_recordings.cfg" appended.  This path
## is loaded on start up.  If you want to change this path at runtime, you must
## also call load_config_file() after setting it, if you want to load the file.
@export var save_path : String = "" :
	set(val):
		if(inst != null):
			inst.save_path = val
		save_path = val


signal playback_done


func _ready():
	inst = scene.instantiate()
	add_child(inst)
	custom_minimum_size = inst.custom_minimum_size
	inst.anchors_preset = PRESET_FULL_RECT
	inst.size = size
	
	resized.connect(_on_resized)
	save_path = save_path

func _on_resized():
	inst.size = size
