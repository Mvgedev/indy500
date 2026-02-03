extends Node2D

# UI Elements
@onready var menu: Control = $CanvasLayer/Menu
@onready var settings: Control = $CanvasLayer/Settings
@onready var controls_mapper: ControlMapper = $"CanvasLayer/Controls Mapper"
@onready var game_settings: Control = $"CanvasLayer/Game Settings"

func _ready() -> void:
	menu.connect("display_settings", display_settings)
	menu.connect("display_game_prep", display_game_prep)
	settings.connect("show_input_mapper", display_mapper)
	settings.connect("close_settings", close_settings)
	controls_mapper.connect("close_input_mapper", close_mapper)
	game_settings.connect("close_game_settings", close_game_prep)
	pass

## Signals
func display_settings():
	menu.visible = false
	settings.visible = true
	pass

func display_mapper():
	settings.visible = false
	controls_mapper.visible = true
	pass

func display_game_prep():
	menu.visible = false
	game_settings.visible = true

func close_mapper():
	controls_mapper.visible = false
	settings.visible = true
	pass

func close_settings():
	settings.visible = false
	menu.visible = true
	pass

func close_game_prep():
	game_settings.visible = false
	menu.visible = true
