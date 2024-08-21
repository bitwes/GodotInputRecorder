extends Node2D

@onready var controls = $InputRecorder

func _on_normal_pressed() -> void:
	controls.display_normal()


func _on_record_pressed() -> void:
	controls.display_record()


func _on_play_pressed() -> void:
	controls.display_play()
