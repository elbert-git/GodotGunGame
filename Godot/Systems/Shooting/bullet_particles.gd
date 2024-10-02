extends CPUParticles3D

@export var id:int = -1

func activate(position:Vector3):
	global_position = position
	self.restart()
	emitting = true
