extends CharacterBody2D # gains base scripting of CharacterBody2D class
var Velocity = 0
var wheel_base = 70 #distance between axles
var steering_angle = 30 #front wheel in degrees, steering tightness
var engine_power = 900 # self explanatory
var acceleration # empty declared variable
var steer_direction # empty declared variable
var friction = -55
var drag = -0.06
var braking = -300
var max_speed_reverse = 250
var slip_speed = 300
var traction_vfast = -2.5
var traction_fast = 2.5
var traction_slow = 30
var drift = 0
@export var max_speed = 500
@export var steer_force = 0.1
@export var look_ahead = 1.3
@export var num_rays = 8
@export var ray_directions = []
@export var interest = []
@export var danger = []
@export var chosen_dir = Vector2.ZERO

func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)

func _physics_process(delta):
	acceleration = Vector2.ZERO # gives accel a base vector of 0 (added to later in script)
	get_input() # names later function
	apply_friction(delta)
	calculate_steering(delta) #names later function
	velocity += acceleration * delta #calculate the increase in speed
	move_and_slide() # names later function but also unsure what to do here
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func set_interest():
	# Set interest in each slot based on world direction
	if owner and owner.has_method("get_path_direction"):
		var path_direction = owner.get_path_direction(position)
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

func get_input():
	if owner and owner.has_method("get_path_direction"):
		var path_direction = owner.get_path_direction(position)
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	# Choose direction based on remaining interest
	for i in num_rays:
		var turn = 0 + ray_directions[i] * interest[i] #get_axis means to opposed inputs
		steer_direction = turn * deg_to_rad(steering_angle)
	# ^ input multiplied by steering_angle variable converted from degrees to radians
		
func calculate_steering(delta):
	# wheel positions
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# move forwards
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	#find new direction vector
	var traction = traction_slow
	if velocity.length() > slip_speed and velocity.length() < 400:
		traction = traction_fast
	if velocity.length() > slip_speed and velocity.length() > 400:
		traction = traction_vfast
	var new_heading = (front_wheel - rear_wheel).normalized()
	#set new velocity and rotation
	drift = new_heading.dot(velocity.normalized())
	if drift > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), (traction / 12) * delta)
	if drift < 0:
		velocity = - new_heading * min(velocity.length(), max_speed_reverse)
	if velocity.length() > 500:
		steering_angle = 30 - ((velocity.length() / 50) + 2)
	if velocity.length() < 500:
		steering_angle = 30
	rotation = new_heading.angle()
	Velocity = velocity.length() / 10
