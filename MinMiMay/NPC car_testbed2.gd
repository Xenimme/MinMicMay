extends CharacterBody2D
var Velocity = 0
var wheel_base = 70
var acceleration = Vector2.ZERO
var steering_angle = 32.5
var interest = 0
var FOREDET
var friction = -55
var drag = -0.06
var min_speed = 0
var engine_power = 900
var brake = 300
var dir
var RayLeft = []
var RayRight = []
var IntLeft : float
var IntRight : float
var max_speed_reverse = 250
var slip_speed = 150
var traction_vfast = -2.5
var traction_fast = 2.5
var traction_slow = 30
var drift = 0
var steer_direction : float
var turn : float
var FOREDETNOR : Vector2
var Globo = Vector2.ZERO

func _physics_process(delta):
	# velocity = -transform.x * engine_power
	collision_detection(delta)
	# Printit(delta)
	set_speed()
	set_interest(delta)
	move_and_slide()
	velocity += acceleration * delta
	Globo = get_global_position()
	FOREDET = $RayCastFore2.result
	FOREDETNOR = $RayCastFore2.get_collision_normal()
	apply_friction(delta)
	steerage(delta)
func set_speed():
	if FOREDET == 0:
		acceleration = -transform.x * engine_power
	else:
		acceleration = -transform.x * brake
		
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
		turn = 40
	elif FOREDET != 0 and IntLeft > IntRight:
		turn = - 40
	else:
		turn = 0
	#get_axis means to opposed inputs
	steer_direction = turn * deg_to_rad(steering_angle)
	# ^ input multiplied by steering_angle variable converted from degrees to radians
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# move forwards
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	rotation = new_heading.angle()
	drift = new_heading.dot(velocity.normalized())
	var traction = traction_slow
	if velocity.length() > slip_speed and velocity.length() < 400:
		traction = traction_fast
	if velocity.length() > slip_speed and velocity.length() > 400:
		traction = traction_vfast
	if drift > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), (traction) * delta)
	if drift < 0:
		velocity = - new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
	Velocity = velocity.length() / 10
# func Printit(delta):
	# print(danger)
	# print(distance)
	# print(FOREDET)
	# print(IntRight)
	# print(IntLeft)
	print(FOREDETNOR)
