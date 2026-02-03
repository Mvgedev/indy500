extends Control

signal display_settings()

func _on_settings_pressed() -> void:
	emit_signal("display_settings")
