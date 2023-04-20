extends CharacterBody2D

@export var max_speed = 500
@export var steer_force = 0.1
@export var look_ahead = 1.3
@export var num_rays = 8
# context array

var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO

var acceleration = Vector2.ZERO

func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)

func _physics_process(delta):
	velocity = Vector2.ZERO
	set_interest()
	set_danger()
	choose_direction()
	var desired_velocity = chosen_dir.rotated(rotation) * max_speed
	velocity = velocity.lerp(desired_velocity, steer_force)
	rotation = velocity.angle()
	move_and_collide(velocity * delta)
	
func set_interest():
	# Set interest in each slot based on world direction
	if owner and owner.has_method("get_h_offset"):
		var path_direction = owner.get_h_offset()
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
		if result:
			danger[i] = 1.0 
		else:
			danger[i] = 0.0
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
#func calculate_steering(delta):
#var rear_wheel = position - transform.x * wheel_base / 2.0
#var front_wheel = position + transform.x * wheel_base / 2.0
#rear_wheel += velocity * delta
#front_wheel += velocity.rotated(steer_angle) * delta
#var new_heading = (front_wheel - rear_wheel).normalized()
#var d = new_heading.dot(velocity.normalized())
#if d > 0:
#    velocity = new_heading * velocity.length()
#if d < 0:
#    velocity = -new_heading * min(velocity.length(), max_speed_reverse)
#rotation = new_heading.angle()
#
#
#
#
#
func get_path_direction():
	$Path2D.get_progress()
	return $Path2D.transform.x
#func _physics_process(delta):
#	move_and_collide()
	
	

#@onready var _follow :PathFollow2D = get_parent()
#var _speed :float = 300.0
#
#func _physics_process(delta):
#	_follow.set_progress(_follow.get_progress() + _speed * delta)
