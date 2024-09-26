extends Node

func map_range(val:float, min_a:float, max_a:float, min_b:float, max_b:float, clamp=false):
	var normalized = (val - min_a)/(max_a-min_a)
	var remapped = min_b + normalized*(max_b-min_b)
	if clamp:
		remapped = clamp(remapped, min_b, max_b)
	return remapped


func lerp(start, end, t, clamp=false):
	var result = (1 - t) * start + t * end
	if clamp:
		if start < end:
			return max(start, min(result, end))
		else:
			return max(end, min(result, start))
	return result
