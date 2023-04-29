extends AnimatedSprite2D

var sprite = ["0", "2"]
@onready var colour = sprite[randi() % sprite.size()]
# Called when the node enters the scene tree for the first time.
func _ready():
	set_animation(colour)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
