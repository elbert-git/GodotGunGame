extends GPUParticles3D

func _process(delta):
	if(Input.is_action_just_pressed("shoot")):
		print("ss")
		emitting = false
		emitting = true
 
