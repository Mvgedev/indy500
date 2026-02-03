extends Control

signal display_settings()
signal display_game_prep()

func _on_settings_pressed() -> void:
	emit_signal("display_settings")


func _on_play_pressed() -> void:
	emit_signal("display_game_prep")
