extends HBoxContainer
class_name ActionBind

@onready var action_key: Label = $Action_Key
@onready var event_key: Button = $Event_Key

var mapper : ControlMapper = null
var id := 0

func _ready() -> void:
	if mapper:
		mapper.refresh_content(self)

func update_action(action: String, event: String) -> void:
	action_key.text = action
	event_key.text = event

func _on_event_key_pressed() -> void:
	mapper.action_bind_pressed(id)
	pass # Replace with function body.
