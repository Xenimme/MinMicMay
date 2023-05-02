extends CharacterBody2D
var Velocity = Vector2.ZERO
var wheel_base = 70
var acceleration = Vector2.ZERO
var steering_angle = 10
var interest = 0
var FOREDET
var friction = -55
var drag = -0.06
var min_speed = 0
var engine_power = 500
var brake = (engine_power * -1)
var dir
var RayLeft = []
var RayRight = []
var IntLeft : float
var IntRight : float
var max_speed_reverse = 250
var slip_speed = 300
var traction_vfast = -2.5
var traction_fast = 20
var traction_slow = 30
var drift = 0
var steer_direction : float
var turn : float
var FOREDETNOR : Vector2
var Globo = Vector2.ZERO
var braking
func _physics_process(delta):
	velocity = Velocity.normalized() * engine_power
#	if Velocity.y > engine_power:
#		Velocity.y = engine_power
#	elif Velocity.y < (engine_power * -1):
#		Velocity.y = (engine_power * -1)
#	if Velocity.x > engine_power:
#		Velocity.x = engine_power
#	elif Velocity.x < (engine_power * -1):
#		Velocity.x = (engine_power * -1)
	collision_detection(delta)
	# Printit(delta)
	set_speed(delta)
	set_interest(delta)
	move_and_slide()
	Velocity += acceleration * delta
	Globo = get_global_position()
	FOREDET = $RayCastFore2.result
	apply_friction(delta)
	steerage(delta)
func set_speed(delta):
	if FOREDET == 0:
		acceleration = transform.x * engine_power
	else:
		acceleration = transform.x * brake * delta
func apply_friction(delta):
	var friction_force = velocity * friction * delta
	var drag_force = Velocity * Velocity.length() * drag * delta
	acceleration += drag_force * friction_force

func collision_detection(_delta):
	RayLeft = [$RayCastRearLeft2.result * 0.2, $RayCastLeft2.result * 0.5, $RayCastForeLeft2.result * 2]
	RayRight = [$RayCastForeRight2.result * 0.2, $RayCastRight2.result * 0.5, $RayCastRearRight2.result * 2]




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
	if Velocity.length() > slip_speed:
		traction = traction_fast
	if drift > 0:
		Velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if drift < 0:
		Velocity = new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()

	print(velocity)
	print(velocity.length())
