@icon("uid://mhfmwvqocaq6")
class_name PlayerMovementController
extends Node


@export var body: CharacterBody3D
@export_group("Speed", "speed")
@export var speed_walk: float = 5.0
@export var speed_sprint: float = 7.5
@export var speed_jump_velocity: float = 5.0
@export_group("Physics")
@export_subgroup("Acceleration")
@export var acceleration: float = 10.0
@export var air_acceleration: float = 10.0
@export var air_wish_speed_cap: float = 0.7
@export_subgroup("Stopping Powers")
@export var friction: float = 4.0
@export var stop_speed: float = 2.0
@export_group("Controls", "action")
@export_subgroup("Abilities")
@export var action_jump: String = "player_jump"
@export var action_sprint: String = "player_run"
@export_subgroup("Movement", "action_move")
@export var action_move_forward: String = "player_forward"
@export var action_move_backward: String = "player_backward"
@export var action_move_left: String = "player_left"
@export var action_move_right: String = "player_right"
 
 
func _ready():
	if not body:
		body = get_parent() as CharacterBody3D
	assert(body, "Player body is not specified or found.")
 
 
func _apply_friction(delta: float):
	var horizontal := Vector3(body.velocity.x, 0, body.velocity.z)
	var speed := horizontal.length()

	if speed < 0.01:
		body.velocity.x = 0
		body.velocity.z = 0
		return
	
	var control_speed := maxf(speed, stop_speed)
	var speed_drop := control_speed * friction * delta 
	var new_speed := maxf((speed - speed_drop), 0)
	var scale := new_speed / speed

	body.velocity.x *= scale
	body.velocity.z *= scale


func _accelerate(wish_dir:Vector3, wish_speed:float, speed_cap: float , accel:float, delta:float):
	var capped_speed := minf(wish_speed, speed_cap)
	var current_speed := body.velocity.dot(wish_dir)
	var add_speed := capped_speed - current_speed

	if add_speed <= 0: return

	var accel_speed := minf(accel * wish_speed * delta, add_speed)
	body.velocity += wish_dir * accel_speed


func _physics_process(delta: float):
	var grounded := body.is_on_floor()
	var jumped := false

	if not grounded:
		body.velocity += body.get_gravity() * delta
	elif action_jump and Input.is_action_just_pressed(action_jump):
		body.velocity.y = speed_jump_velocity
		jumped = true
	if grounded and not jumped:
		_apply_friction(delta)
	
	_move(delta, grounded)
	body.move_and_slide()


func _get_target_speed() -> float:
	if action_sprint and Input.is_action_pressed(action_sprint):
		return speed_sprint
	return speed_walk


func _move(delta: float, grounded: bool):
	var input := Input.get_vector(
		action_move_left, action_move_right,
		action_move_forward, action_move_backward)

	if not input:
		return

	var direction := body.global_basis * Vector3(input.x, 0, input.y)
	var wish_dir := direction.normalized()
	var wish_speed := _get_target_speed() * input.length()

	if grounded:
		_accelerate(wish_dir, wish_speed, wish_speed, acceleration, delta)
	else:
		_accelerate(wish_dir, wish_speed, air_wish_speed_cap, air_acceleration, delta)
 
