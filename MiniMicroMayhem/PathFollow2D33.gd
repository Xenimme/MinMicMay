extends PathFollow2D

func get_path_direction(pos):
	var offset = Path2D.curve.get_closest_offset(pos)
	PathFollow2D.h_offset = offset
	return PathFollow2D.transform.x
