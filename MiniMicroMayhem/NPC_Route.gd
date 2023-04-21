extends PathFollow2D

func get_path_direction(pos):
	progress = $"..".curve.get_closest_offset(pos)
	return transform.x
