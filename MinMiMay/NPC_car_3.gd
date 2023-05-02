extends CharacterBody2D
var wheel_base = 70
var acceleration = Vector2.ZERO
var steering_angle = randf_range (33.5, 36.5)
var interest = 0
var FOREDET
var friction = -55
var drag = -0.06
var min_speed = 0
var engine_power = randf_range(460, 540)
var brake = - engine_power * 0.08
var dir
var RayLeft = []
var RayRight = []
var IntLeft : float
var IntRight : float
var max_speed_reverse = 250
var slip_speed = 350
var traction_slow = 32
var traction_fast = (traction_slow * 0.16)
var drift = 0
var steer_direction : float
var turn : float
var FOREDETNOR : Vector2
var Globo = Vector2.ZERO
var braking
var Velocity = Vector2.ZERO
func _physics_process(delta):
	velocity.clamp(Vector2.ZERO, velocity.normalized() * (engine_power - 100))
	if velocity.length() > engine_power:
		velocity = velocity.normalized() * engine_power
	collision_detection(delta)
	# Printit(delta)
	set_speed()
	set_interest(delta)
	move_and_slide()
	velocity += acceleration * delta
	Globo = get_global_position()
	FOREDET = $RayCastFore2.result
	apply_friction(delta)
	steerage(delta)
	
func set_speed():
	if FOREDET == 0:
		acceleration = transform.x * (engine_power * randf_range(1.2, 0.7))
	else:
		acceleration = transform.x * brake
func apply_friction(delta):
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force * friction_force

func collision_detection(_delta):
	RayLeft = [$RayCastRearLeft2.result, $RayCastLeft2.result, $RayCastForeLeft2.result]
	RayRight = [$RayCastForeRight2.result, $RayCastRight2.result, $RayCastRearRight2.result]




func set_interest(_delta):
	RayLeft.sort()
	RayRight.sort()
	
	IntLeft = RayRight[0] + RayRight[1] + RayRight[2]
	IntRight = RayLeft[0] + RayLeft[1] + RayLeft[2]


func steerage(delta):
	if FOREDET != 0 and IntRight > IntLeft:
		turn = 1
	elif FOREDET != 0 and IntLeft > IntRight:
		turn = -1
	else:
		turn = 0
	#get_axis means to opposed inputs
	steer_direction = turn * deg_to_rad(steering_angle)
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta # always tries to push forwards
	front_wheel += velocity.rotated(steer_direction) * delta # will move at steering angle
	var new_heading = (front_wheel - rear_wheel).normalized() # if front/rear are +/- 1 respectively, new heading is the difference
	rotation = new_heading.angle() # rotation is the above as an angle
	drift = new_heading.dot(velocity.normalized()) # new_heading's individual parts (a) times velocity's individual parts (b) with one x by cos of their angle. So (XA * XB) + (YY * YB) with A and B meaning the cos of a or b/
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	if drift > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if drift < 0:
		velocity = new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
	#Velocity = velocity.length() / 10

	print(velocity)
	print(velocity.length())
