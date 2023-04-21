extends CharacterBody2D
@onready var _follow :Path2D = get_parent()
var _speed :float = 300.0

func _physics_process(delta):
	_follow.set_progress(_follow.get_progress() + _speed * delta)
