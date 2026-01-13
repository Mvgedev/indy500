extends Control
class_name ControlMapper

# ActionBinds
## P1
@onready var p_1_steer_left: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P1 Steer Left"
@onready var p_1_steer_right: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P1 Steer Right"
@onready var p_1_throttle: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P1 Throttle"
@onready var p_1_brake: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P1 Brake"
@onready var p_1_h_brake: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P1 HBrake"
## P2
@onready var p_2_steer_left: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P2 Steer Left"
@onready var p_2_steer_right: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P2 Steer Right"
@onready var p_2_throttle: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P2 Throttle"
@onready var p_2_brake: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P2 Brake"
@onready var p_2_h_brake: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/P2 HBrake"
## UI
@onready var ui_left: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/UI Left"
@onready var ui_right: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/UI Right"
@onready var ui_up: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/UI Up"
@onready var ui_down: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/UI Down"
@onready var ui_confirm: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/UI Confirm"
@onready var ui_cancel: ActionBind = $"TextureRect/Container/VBoxContainer/ScrollContainer/MarginContainer/ActionsContainer/UI Cancel"

# Waiting for Input Animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var waiting_for_input = false
var selected_actionbind = -1
var input_map := []
var binds := []

func _ready() -> void:
	fill_input_map()
	# P1 binds
	init_actionBind(p_1_steer_left, 0)
	init_actionBind(p_1_steer_right, 1)
	init_actionBind(p_1_throttle, 2)
	init_actionBind(p_1_brake, 3)
	init_actionBind(p_1_h_brake, 4)
	# P2 binds
	init_actionBind(p_2_steer_left, 5)
	init_actionBind(p_2_steer_right, 6)
	init_actionBind(p_2_throttle, 7)
	init_actionBind(p_2_brake, 8)
	init_actionBind(p_2_h_brake, 9)
	# UI binds
	init_actionBind(ui_left, 10)
	init_actionBind(ui_right, 11)
	init_actionBind(ui_up, 12)
	init_actionBind(ui_down, 13)
	init_actionBind(ui_confirm, 14)
	init_actionBind(ui_cancel, 15)

func init_actionBind(act : ActionBind, id: int):
	act.mapper = self
	act.id = id
	refresh_content(act)
	
func fill_input_map():
	#P1 Input
	input_map.append({InputSystem.P1_LSTEER_KEY: InputSystem.get_input_for_key(InputSystem.P1_LSTEER_KEY)})
	input_map.append({InputSystem.P1_RSTEER_KEY: InputSystem.get_input_for_key(InputSystem.P1_RSTEER_KEY)})
	input_map.append({InputSystem.P1_THROTTLE_KEY: InputSystem.get_input_for_key(InputSystem.P1_THROTTLE_KEY)})
	input_map.append({InputSystem.P1_BRAKE_KEY: InputSystem.get_input_for_key(InputSystem.P1_BRAKE_KEY)})
	input_map.append({InputSystem.P1_HANDBRAKE_KEY: InputSystem.get_input_for_key(InputSystem.P1_HANDBRAKE_KEY)})
	binds.append_array([p_1_steer_left, p_1_steer_right, p_1_throttle, p_1_brake, p_1_h_brake])
	#P2 Input
	input_map.append({InputSystem.P2_LSTEER_KEY: InputSystem.get_input_for_key(InputSystem.P2_LSTEER_KEY)})
	input_map.append({InputSystem.P2_RSTEER_KEY: InputSystem.get_input_for_key(InputSystem.P2_RSTEER_KEY)})
	input_map.append({InputSystem.P2_THROTTLE_KEY: InputSystem.get_input_for_key(InputSystem.P2_THROTTLE_KEY)})
	input_map.append({InputSystem.P2_BRAKE_KEY: InputSystem.get_input_for_key(InputSystem.P2_BRAKE_KEY)})
	input_map.append({InputSystem.P2_HANDBRAKE_KEY: InputSystem.get_input_for_key(InputSystem.P2_HANDBRAKE_KEY)})
	binds.append_array([p_2_steer_left, p_2_steer_right, p_2_throttle, p_2_brake, p_2_h_brake])
	# UI Input
	input_map.append({InputSystem.UI_LEFT_KEY: InputSystem.get_input_for_key(InputSystem.UI_LEFT_KEY)})
	input_map.append({InputSystem.UI_RIGHT_KEY: InputSystem.get_input_for_key(InputSystem.UI_RIGHT_KEY)})
	input_map.append({InputSystem.UI_UP_KEY: InputSystem.get_input_for_key(InputSystem.UI_UP_KEY)})
	input_map.append({InputSystem.UI_DOWN_KEY: InputSystem.get_input_for_key(InputSystem.UI_DOWN_KEY)})
	input_map.append({InputSystem.UI_ACCEPT_KEY: InputSystem.get_input_for_key(InputSystem.UI_ACCEPT_KEY)})
	input_map.append({InputSystem.UI_CANCEL_KEY: InputSystem.get_input_for_key(InputSystem.UI_CANCEL_KEY)})
	binds.append_array([ui_left, ui_right, ui_up, ui_down, ui_confirm, ui_cancel])

func refresh_content(bind : ActionBind) -> void:
	var action = input_map[bind.id]
	if action:
		bind.update_action(action.keys()[0], action.values()[0])

func action_bind_pressed(id):
	if waiting_for_input == false:
		selected_actionbind = id
		waiting_for_input = true
		animation_player.play("waiting_for_input")

# Waiting for remap
func _input(event: InputEvent) -> void:
	if waiting_for_input and event:
		var key = input_map[selected_actionbind].keys()[0]
		# Keyboard
		if event is InputEventKey and event.pressed:
			InputSystem.set_input_for_key(key, event)
			input_map[selected_actionbind][key] = InputSystem.get_input_for_key(key)
		elif event is InputEventJoypadButton and event.pressed:
			pass
		elif event is InputEventJoypadMotion and abs(event.axis_value) > InputSystem.DEADZONE:
			pass
		elif event is InputEventMouseButton and event.pressed:
			pass
		else:
			return
		InputSystem.save_inputs()
		refresh_content(binds[selected_actionbind])
		waiting_for_input = false
		selected_actionbind = -1
		animation_player.play("RESET")
		
