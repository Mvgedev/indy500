extends Control

@onready var fx_slider: HSlider = $"VBoxContainer/Sound Slider/FXSlider"
@onready var bgm_slider: HSlider = $"VBoxContainer/Music Slider/BGMSlider"

signal show_input_mapper()
signal close_settings()

## Signals
func _on_input_mapping_pressed() -> void:
	emit_signal("show_input_mapper")
func _on_fx_slider_drag_ended(value_changed: bool) -> void:
	pass # Replace with function body.
func _on_bgm_slider_drag_ended(value_changed: bool) -> void:
	pass # Replace with function body.
func _on_back_button_pressed() -> void:
	emit_signal("close_settings")
