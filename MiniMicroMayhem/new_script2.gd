extends CharacterBody2D

@export var max_speed = 0.01
@export var steer_force = 0.1
@export var look_ahead = 100
@export var num_rays = 8
@export var friction = -55
@export var drag = -0.06
@export var braking = -300
@export var max_speed_reverse = 250
@export var slip_speed = 300
@export var traction_vfast = -2.5
@export var traction_fast = 2.5
@export var traction_slow = 30
@export var drift = 0
# context array
var ray_directions = []
var interest = []
var danger = []
var chosen_dir = Vector2.ZERO
var acceleration = Vector2.ZERO
var _follow :PathFollow2D

func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)

func _physics_process(delta):
	set_interest()
	set_danger()
	choose_direction()
	var desired_velocity = chosen_dir.rotated(rotation) * max_speed
	velocity = velocity.lerp(desired_velocity, steer_force)
	rotation = velocity.angle()
	apply_friction(delta)
	move_and_collide(velocity * delta)

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func set_interest():
	# Set interest in each slot based on world direction
	if $".." and $"..".has_method("get_path_direction"):
		var path_direction = $"..".get_path_direction(global_position)
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	# If no world path, use default interest
	else:
		set_default_interest()

func set_default_interest():
	# Default to moving forward
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0, d)
		
func set_danger():
	# Cast rays to find danger directions
	var params = PhysicsRayQueryParameters2D.new()
	params.from = position
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(params)
		danger[i] = 1.0 if result else 0.0
		params.to = position + ray_directions[i].rotated(rotation) * look_ahead
	params.exclude = [self]
		
func choose_direction():
	# Eliminate interest in slots with danger
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	# Choose direction based on remaining interest
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
