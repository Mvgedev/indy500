extends CharacterBody2D

@onready var car_sprite: AnimatedSprite2D = $"Car Sprite"
@onready var shadow: Sprite2D = $Shadow

@onready var pathing_raycast: RayCast2D = $"Pathing Raycast"

# Wheels RC
@onready var up_left_wheel_rc: RayCast2D = $"Wheels RC/UpLeftWheelRC"
@onready var down_left_wheel_rc: RayCast2D = $"Wheels RC/DownLeftWheelRC"
@onready var up_right_wheel_rc: RayCast2D = $"Wheels RC/UpRightWheelRC"
@onready var down_right_wheel_rc: RayCast2D = $"Wheels RC/DownRightWheelRC"



var h_brake = false
# TRACK VALUE
const TOP_SPEED = 200.0
const REV_SPEED = -80.0
const FRICTION_SPD = 150.0
const GRIP = 550.0

# SAND VALUE
const SAND_SPEED = 20.0
const SAND_REV = -15.0
const SAND_FRICTION = 400.0
const SAND_GRIP = 400.0

# ICE VALUE
const ICE_SPEED = 200.0
const ICE_REV = -80.0
const ICE_FRICTION = 10.0
const ICE_GRIP = 30.0

# Used Value
var local_top_speed = TOP_SPEED
var local_rev_speed = REV_SPEED
var local_friction = FRICTION_SPD
var local_grip = GRIP

enum TERRAIN {SAND, ICE, DIRT, GRASS}
var ground_terrain = TERRAIN.SAND

const ACCEL = 100.0
const BRAKE_SPD = 150.0

const HBRAKE_STEER = 1.2
const HBRAKE_DRIFT_MOD = 0.8

const STEERING_SPD = 5

# COLLISIONS
const MAX_IMPACT = 200.0
const IMP_BOUNCE = 0.25
const MIN_SPEED_CRASH = 0.35

var cur_speed = 0.0
var lat_speed = 0.0
var pace := CAR_PACE.STILL

enum CAR_PACE {STILL, SLOW, MID, FAST, REVERSE}

var on_road = true


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
	
	var road_ratio = get_road_contact_ratio()
	terrain_modifier(road_ratio)
	# Handle Throttle speed
	throttle_management(throttle, delta)
	# Handle Steering
	var speed_ratio = abs(cur_speed) / local_top_speed
	var steering_strength = steering_management(steering, speed_ratio)
	if h_brake:
		steering_strength *= HBRAKE_STEER
	rotation += steering * steering_strength * delta * sign(cur_speed)
	# Move
	var forward := Vector2.UP.rotated(rotation) # Vector2.UP -> Front object direction, rotation -> car orientation (coded by steering axis)
	var right = forward.orthogonal() # Slide motion
	
	lat_speed = velocity.dot(right)
	var cur_grip = local_grip
	if h_brake:
		cur_speed = move_toward(cur_speed, 0.0, BRAKE_SPD * delta)
		cur_grip *= HBRAKE_DRIFT_MOD
	lat_speed = move_toward(lat_speed, 0.0, cur_grip * delta)
	
	var max_lateral = abs(cur_speed) * 0.75
	lat_speed = clamp(lat_speed, -max_lateral, max_lateral)
	
	velocity = forward * cur_speed + right * lat_speed
	var velocity_ref = velocity
	move_and_slide()
	
	var strongest_impact = 0.0
	var impact_normal = Vector2.ZERO
	
	for i in get_slide_collision_count(): # Detect collision
		var collision = get_slide_collision(0)
		var normal = collision.get_normal()
		var impact_strength = -velocity_ref.dot(normal)
		if impact_strength > strongest_impact:
			strongest_impact = impact_strength
			impact_normal = normal
	if strongest_impact > 0.0:
		var impact_coeff = clamp(strongest_impact / MAX_IMPACT, 0.0, 1.0)
		cur_speed *= lerp(1.0, MIN_SPEED_CRASH, impact_coeff)
		lat_speed *= lerp(1.0, 0.5, impact_coeff)
		velocity += impact_normal * min(strongest_impact, MAX_IMPACT) * IMP_BOUNCE

	cur_speed = velocity.dot(forward)
	lat_speed = velocity.dot(right)
	# Animation
	handle_pace(cur_speed)

func terrain_modifier(road_ratio):
	match ground_terrain:
		TERRAIN.SAND:
			local_friction = lerp(SAND_FRICTION, FRICTION_SPD, road_ratio)
			local_grip = lerp(SAND_GRIP, GRIP, road_ratio)
			local_top_speed = lerp(SAND_SPEED, TOP_SPEED, road_ratio)
			local_rev_speed = lerp(SAND_REV, REV_SPEED, road_ratio)
		TERRAIN.ICE:
			local_friction = lerp(ICE_FRICTION, FRICTION_SPD, road_ratio)
			local_grip = lerp(ICE_GRIP, GRIP, road_ratio)
			local_top_speed = lerp(ICE_SPEED, TOP_SPEED, road_ratio)
			local_rev_speed = lerp(ICE_REV, REV_SPEED, road_ratio)
		TERRAIN.DIRT:
			pass
		TERRAIN.GRASS:
			pass
	
	

func steering_management(steering, speed_ratio) -> float:
	if steering == 0.0:
		return 0.0
	if speed_ratio < 0.1:
		return 0.0
	return lerp(0.95, 0.7, speed_ratio) * STEERING_SPD

func throttle_management(throttle, delta):
	if throttle != 0:
		cur_speed += throttle * ACCEL * delta
	else:
		cur_speed = move_toward(cur_speed, 0, local_friction * delta)
	cur_speed = clamp(cur_speed, local_rev_speed, local_top_speed)


func handle_pace(speed):
	var new_pace = define_pace(speed)
	if new_pace != pace:
		pace = new_pace
		refresh_pace_anim()

func refresh_pace_anim():
	if pace == CAR_PACE.STILL:
		car_sprite.play("idle")
	elif pace == CAR_PACE.REVERSE:
		car_sprite.play("reverse")
	else:
		car_sprite.play("forward")
	match pace:
		CAR_PACE.STILL:
			car_sprite.speed_scale = 0.0
		CAR_PACE.REVERSE:
			car_sprite.speed_scale = 1.0
		CAR_PACE.SLOW:
			car_sprite.speed_scale = 0.3
		CAR_PACE.MID:
			car_sprite.speed_scale = 0.6
		CAR_PACE.FAST:
			car_sprite.speed_scale = 1.0

func define_pace(speed) -> CAR_PACE:
	var speed_ratio = abs(speed) / TOP_SPEED
	if speed < 0.0:
		return CAR_PACE.REVERSE
	elif speed_ratio < 0.05:
		return CAR_PACE.STILL
	elif speed_ratio < 0.3:
		return CAR_PACE.SLOW
	elif speed_ratio < 0.7:
		return CAR_PACE.MID
	else:
		return CAR_PACE.FAST

func get_road_contact_ratio() -> float:
	var hits := 0
	var rays := [up_left_wheel_rc, up_right_wheel_rc, down_left_wheel_rc, down_right_wheel_rc]
	for ray in rays:
		if ray.is_colliding():
			hits += 1
	return hits / float(rays.size()) # Return 1.0 if all car on track, 0.75 if one wheel out, 0.5 if half out and so on
