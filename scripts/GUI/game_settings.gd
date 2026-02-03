extends Control

@onready var player_toggle: CheckButton = $"VBoxContainer/Players Toggle/PlayerToggle"
@onready var game_mode_label: Label = $VBoxContainer/Modes/GameModeLabel
var modes = ["RACE", "TIME TRIAL", "COIN BATTLE"]
var game_mode = 0

signal start_game(players, mode, track)
signal close_game_settings()

func change_game_mode(val):
	game_mode += val
	if game_mode < 0:
		game_mode = modes.size() - 1
	elif game_mode > modes.size() - 1:
		game_mode = 0
	game_mode_label.text = modes[game_mode]
	if game_mode == 1:
		player_toggle.button_pressed = false
		

## Signals
### Game Mode
func _on_prev_mode_pressed() -> void:
	change_game_mode(-1)

func _on_next_mode_pressed() -> void:
	change_game_mode(1)

func _on_back_button_pressed() -> void:
	emit_signal("close_game_settings")
## Players Number
func _on_player_toggle_pressed() -> void:
	if game_mode == 1:
		player_toggle.button_pressed = false
