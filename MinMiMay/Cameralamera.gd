extends Camera2D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_released("Zoom Out"):
		set_zoom(get_zoom() - Vector2(0.025, 0.025))
	if Input.is_action_just_released("Zoom In"):
		set_zoom(get_zoom() + Vector2(0.025, 0.025))
