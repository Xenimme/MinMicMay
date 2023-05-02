extends RayCast2D
# Called when the node enters the scene tree for the first time.
var result : float = 0
func _ready():
	collide_with_areas = true
	collide_with_bodies = true
	collision_mask = 1
	enabled = true
	exclude_parent = true


func _physics_process(_delta):
	Collisional()
	
		
func Collisional():
	var collision_point: Vector2 = get_collision_point()
	if is_colliding():
		var origin: Vector2 =  get_global_position()
		result = origin.distance_to(collision_point)
	else:
		result = 0
		# if result:
			# print(result)
