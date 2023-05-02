extends CharacterBody2D # gains base scripting of CharacterBody2D class
var Velocity = 0
var wheel_base = 70 #distance between axles
var steering_angle = 32.5 #front wheel in degrees, steering tightness
var engine_power = 850 # self explanatory
var acceleration # empty declared variable
var steer_direction # empty declared variable
var friction = -55
var drag = -0.06
var braking = (engine_power * -1)
var max_speed_reverse = 250
var slip_speed = 300
var traction_fast = randf_range(2.3, 3.0)
var traction_slow = randf_range(28, 32)
var drift = 0


func _physics_process(delta):
	acceleration = Vector2.ZERO # gives accel a base vector of 0 (added to later in script)
	get_input(delta) # names later function
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

func get_input(_delta):
	var turn = Input.get_axis("steer_left", "steer_right") #get_axis means to opposed inputs
	steer_direction = turn * deg_to_rad(steering_angle)
	# ^ input multiplied by steering_angle variable converted from degrees to radians
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power 
		# ^ position and orientation multiplied by engine power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
		
func calculate_steering(delta):
	# wheel positions
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# move forwards
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	#find new direction vector
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast

	var new_heading = (front_wheel - rear_wheel).normalized()
	#set new velocity and rotation
	drift = new_heading.dot(velocity.normalized())
	if drift > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), (traction /2) * delta)
	if drift < 0:
		velocity = - new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
	Velocity = velocity.length() / 10
	
#	print(velocity.length())
