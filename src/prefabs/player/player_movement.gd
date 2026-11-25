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
@export var air_acceleration: float = 2.0
@export_subgroup("Friction")
@export var friction: float = 8.0
@export var air_friction: float = 0.5
 
@export_group("Controls", "action")
@export var action_jump: String = "ui_accept"
@export var action_sprint: String = ""
@export_subgroup("Move", "action_move")
@export var action_move_forward: String = "ui_up"
@export var action_move_backward: String = "ui_down"
@export var action_move_left: String = "ui_left"
@export var action_move_right: String = "ui_right"


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_friction: float
 
 
func _ready():
	if not body:
		body = get_parent() as CharacterBody3D
	assert(body, "Player body is not specified or found.")
 
 
func _physics_process(delta: float):
	var grounded := body.is_on_floor()

	if not grounded:
		body.velocity += body.get_gravity() * delta
	elif action_jump and Input.is_action_just_pressed(action_jump):
		body.velocity.y = speed_jump_velocity
	
	_move(delta, grounded)

	body.move_and_slide()


func _move(delta: float, grounded: bool):
	var input := Input.get_vector(
		action_move_left, action_move_right,
		action_move_forward, action_move_backward)
	var direction := body.global_basis * Vector3(input.x, 0, input.y)
	var target := direction * _get_target_speed()

	var rate: float
	if input:
		rate = acceleration if grounded else air_acceleration
	else:
		rate = friction if grounded else air_friction

	var horizontal := Vector3(body.velocity.x, 0, body.velocity.z)
	horizontal = horizontal.move_toward(target, rate * delta)
	body.velocity.x = horizontal.x
	body.velocity.z = horizontal.z

 
func _get_target_speed() -> float:
	if action_sprint and Input.is_action_pressed(action_sprint):
		return speed_sprint
	return speed_walk
 
