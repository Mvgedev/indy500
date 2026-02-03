extends Node
class_name InputController

enum PLAYER {PLAYER_1, PLAYER_2}

@export var player = PLAYER.PLAYER_1

func get_brake_input() -> String:
	var ret = ""
	match player:
		PLAYER.PLAYER_1:
			ret = InputSystem.P1_BRAKE_KEY
		PLAYER.PLAYER_2:
			ret = InputSystem.P2_BRAKE_KEY
	return ret

func get_hbrake_input() -> String:
	var ret = ""
	match player:
		PLAYER.PLAYER_1:
			ret = InputSystem.P1_HANDBRAKE_KEY
		PLAYER.PLAYER_2:
			ret = InputSystem.P2_HANDBRAKE_KEY
	return ret

func get_throttle_input() -> String:
	var ret = ""
	match player:
		PLAYER.PLAYER_1:
			ret = InputSystem.P1_THROTTLE_KEY
		PLAYER.PLAYER_2:
			ret = InputSystem.P2_THROTTLE_KEY
	return ret

func get_steeringL_input() -> String:
	var ret = ""
	match player:
		PLAYER.PLAYER_1:
			ret = InputSystem.P1_LSTEER_KEY
		PLAYER.PLAYER_2:
			ret = InputSystem.P2_LSTEER_KEY
	return ret

func get_steeringR_input() -> String:
	var ret = ""
	match player:
		PLAYER.PLAYER_1:
			ret = InputSystem.P1_RSTEER_KEY
		PLAYER.PLAYER_2:
			ret = InputSystem.P2_RSTEER_KEY
	return ret
