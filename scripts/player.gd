extends CharacterBody2D

@onready var car_sprite: AnimatedSprite2D = $"Car Sprite"
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var h_brake = false
const TOP_SPEED = 150
const ACCEL = 200
const BRAKE_SPD = 300
const REV_SPEED = -80
const STEERING_SPD = 5
const FRICTION_SPD = 50

var cur_speed = 0.0
var is_moving = false

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hand_brake"):
		h_brake = true
	elif event.is_action_released("hand_brake"):
		h_brake = false
	pass
	
func _physics_process(delta: float) -> void:
	var throttle = Input.get_axis("brake","throttle")
	var steering = Input.get_axis("steer_left","steer_right")
	# Handle Throttle speed
	if throttle != 0:
		cur_speed += throttle * ACCEL * delta
	else:
		cur_speed = move_toward(cur_speed, 0, FRICTION_SPD * delta)
	cur_speed = clamp(cur_speed, REV_SPEED, TOP_SPEED)
	# Handle Steering
	var speed_ratio = abs(cur_speed) / TOP_SPEED
	var steering_factor = 0.0
	if speed_ratio > 0.05:
		if speed_ratio < 0.45:
			steering_factor = speed_ratio / 0.45
		else:
			steering_factor = lerp(1.0, 0.6, (speed_ratio - 0.45) / (1.0 - 0.45))
	if sign(cur_speed) == -1:
			steering_factor = -0.5
	rotation += steering * STEERING_SPD * delta * steering_factor * sign(cur_speed)
	handle_animation(cur_speed)
	# Move
	var forward := Vector2.UP.rotated(rotation)
	velocity = forward * cur_speed
	move_and_slide()

func handle_animation(speed):
	if cur_speed == 0 and is_moving == true:
		is_moving = false
		car_sprite.play("idle")
	elif cur_speed != 0 and is_moving == false:
		is_moving = true
		car_sprite.play("moving")
