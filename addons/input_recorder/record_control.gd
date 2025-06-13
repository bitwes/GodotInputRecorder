extends ColorRect

signal stop


func _on_stop_pressed() -> void:
	stop.emit()
