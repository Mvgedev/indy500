extends Node

# Config File Const
const INPUT_CFG_PATH = "user://input.cfg"
const INPUT_SECTION_KEY = "input"

# Inputs Consts
## Inputs P1
const P1_LSTEER_KEY = "steer_left"
const P1_RSTEER_KEY = "steer_right"
const P1_THROTTLE_KEY = "throttle"
const P1_BRAKE_KEY = "brake"
const P1_HANDBRAKE_KEY = "hand_brake"
## Inputs P2
const P2_LSTEER_KEY = "p2_lsteer"
const P2_RSTEER_KEY = "p2_rsteer"
const P2_THROTTLE_KEY = "p2_throttle"
const P2_BRAKE_KEY = "p2_brake"
const P2_HANDBRAKE_KEY = "p2_hbrake"
## Inputs UI
const UI_UP_KEY = "ui_up"
const UI_DOWN_KEY = "ui_down"
const UI_LEFT_KEY = "ui_left"
const UI_RIGHT_KEY = "ui_right"
const UI_ACCEPT_KEY = "ui_accept"
const UI_CANCEL_KEY = "ui_cancel"


func _ready() -> void:
	load_inputs()

# Config Save/Load
func save_inputs():
	var cfg = ConfigFile.new()
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		for ev in events:
			if ev is InputEventKey:
				cfg.set_value(INPUT_SECTION_KEY, action, ev.keycode)
	cfg.save(INPUT_CFG_PATH)

func load_inputs():
	var cfg = ConfigFile.new()
	if cfg.load(INPUT_CFG_PATH) == OK:
		for action in cfg.get_section_keys(INPUT_SECTION_KEY):
			remap_action(action, cfg.get_value(INPUT_SECTION_KEY, action))

# Setter/Getter for Inputs
func get_input_for_key(key: String) -> String:
	var setting_path := "input/%s" % key
	if not ProjectSettings.has_setting(setting_path):
		return ""
	var events = ProjectSettings.get_setting(setting_path)["events"]
	for e in events: # Will return the first event only
		if e is InputEventKey:
			if e.keycode != Key.KEY_NONE:
				return OS.get_keycode_string(e.keycode)
			elif e.physical_keycode != Key.KEY_NONE:
				return OS.get_keycode_string(e.physical_keycode)
		elif e is InputEventMouseButton:
			return "Mouse %d" % e.button_index
		elif e is InputEventJoypadButton:
			return "Pad Button %d" % e.button_index
		elif e is InputEventJoypadMotion:
			var dir = "+" if e.axis_value > 0.0 else "-"
			if e.axis > 3 :
				return str_joypad_input(e.axis)
			return "%s(%s)" % [str_joypad_input(e.axis), dir]
	return ""

func str_joypad_input(val) -> String:
	var ret = ""
	match val:
		JOY_AXIS_LEFT_X: ret = "Left Stick X"
		JOY_AXIS_LEFT_Y: ret = "Left Stick Y"
		JOY_AXIS_RIGHT_X: ret = "Right Stick X"
		JOY_AXIS_RIGHT_Y: ret = "Right Stick Y"
		JOY_AXIS_TRIGGER_LEFT: ret = "Left Trigger"
		JOY_AXIS_TRIGGER_RIGHT: ret = "Right Trigger"
	return ret

func set_input_for_key(key: String, input: InputEvent):
	remap_action(key, input.keycode)

func remap_action(key: String, new_input: Key):
	# Clear action from input(s)
	InputMap.action_erase_events(key)
	# Create new input based on Key received
	var event := InputEventKey.new()
	event.keycode = new_input
	event.pressed = false
	# Add input to action
	InputMap.action_add_event(key, event)
