extends Node

# Config File Const
const INPUT_CFG_PATH = "user://input.cfg"
const INPUT_SECTION_KEY = "input"
## Management of cfg file format
const INPUT_EVENT_TYPE = "event_type"
const INPUT_TYPE_KEY = "keyboard"
const INPUT_TYPE_JOYPAD = "joypad_button"
const INPUT_TYPE_JOYSTICK = "joypad_axis"
const INPUT_TYPE_MOUSE = "mouse_button"
const INPUT_KEYCODE = "keycode"
const INPUT_P_KEYCODE = "physical_keycode"
const INPUT_BUTTON_IDX = "button_index"
const INPUT_AXIS = "axis"
const INPUT_AXIS_VALUE = "axis_value"
# Inputs Consts
const DEADZONE = 0.2
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
			var ev_val
			if ev is InputEventKey:
				ev_val = {INPUT_EVENT_TYPE:INPUT_TYPE_KEY, INPUT_KEYCODE:ev.keycode, INPUT_P_KEYCODE:ev.physical_keycode}
			elif ev is InputEventJoypadButton:
				ev_val = {INPUT_EVENT_TYPE:INPUT_TYPE_JOYPAD, INPUT_BUTTON_IDX:ev.button_index}
			elif ev is InputEventJoypadMotion:
				ev_val = {INPUT_EVENT_TYPE:INPUT_TYPE_JOYSTICK, INPUT_AXIS:ev.axis, INPUT_AXIS_VALUE:ev.axis_value}
			elif ev is InputEventMouse:
				ev_val = {INPUT_EVENT_TYPE:INPUT_TYPE_MOUSE, INPUT_BUTTON_IDX:ev.button_index}
			else:
				continue
			cfg.set_value(INPUT_SECTION_KEY, action, ev_val)
	cfg.save(INPUT_CFG_PATH)

func load_inputs():
	var cfg = ConfigFile.new()
	if cfg.load(INPUT_CFG_PATH) == OK:
		for action in cfg.get_section_keys(INPUT_SECTION_KEY):
			var loaded_cfg = load_input_from_cfg(cfg.get_value(INPUT_SECTION_KEY, action))
			set_input_for_key(action, loaded_cfg)
	else:
		for action in InputMap.get_actions():
			var data = ProjectSettings.get_setting("input/%s" % action)
			if data == null:
				continue
			if not data.has("events"):
				continue
			for e in data["events"]:
				set_input_for_key(action, e)
				break
			

# Setter/Getter for Inputs
func get_input_for_key(key: String) -> String:
	var events = InputMap.action_get_events(key)
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

func load_input_from_cfg(cfg) -> InputEvent:
	var ret : InputEvent = null
	var event_type = cfg[INPUT_EVENT_TYPE]
	if event_type == INPUT_TYPE_KEY:
		ret = InputEventKey.new()
		ret.keycode = cfg[INPUT_KEYCODE]
		ret.physical_keycode = cfg[INPUT_P_KEYCODE]
		ret.pressed = false
	elif event_type == INPUT_TYPE_JOYPAD:
		ret = InputEventJoypadButton.new()
		ret.button_index = cfg[INPUT_BUTTON_IDX]
		ret.pressed = false
	elif event_type == INPUT_TYPE_JOYSTICK:
		ret = InputEventJoypadMotion.new()
		ret.axis = cfg[INPUT_AXIS]
		ret.axis_value = cfg[INPUT_AXIS_VALUE]
	elif event_type == INPUT_TYPE_MOUSE:
		ret = InputEventMouseButton.new()
		ret.button_index = cfg[INPUT_BUTTON_IDX]
		ret.pressed = false
	return ret

func set_input_for_key(key: String, input: InputEvent):
	# Create new Event
	var new_event : InputEvent
	if input is InputEventKey:
		new_event = remap_action_for_kb(input)
	elif input is InputEventJoypadButton:
		new_event = remap_action_for_jb(input.button_index)
	elif input is InputEventJoypadMotion:
		new_event = remap_action_for_ja(input.axis, input.axis_value)
	elif input is InputEventMouseButton:
		new_event = remap_action_for_mo(input.button_index)
	else:
		print("Error rebinding input")
		return
	# Clear action from input(s)
	InputMap.action_erase_events(key)
	# Add input to action
	InputMap.action_add_event(key, new_event)

func remap_action_for_kb(new_input: InputEventKey) -> InputEventKey:
	var event := InputEventKey.new()
	if new_input.keycode != 0:
		event.keycode = new_input.keycode
	elif new_input.physical_keycode != 0:
		event.physical_keycode = new_input.physical_keycode
	event.pressed = false
	return event

func remap_action_for_jb(new_input: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = new_input
	event.pressed = false
	return event

func remap_action_for_ja(new_input: JoyAxis, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = new_input
	event.axis_value = value
	return event

func remap_action_for_mo(new_input: MouseButton) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = new_input
	event.pressed = false
	return event
