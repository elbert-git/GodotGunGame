extends Node


# properties  ---------------------------------------------------------------------------------------------------------------
const TOTAL_INSTANCES = 20




# states  ---------------------------------------------------------------------------------------------------------------
var all_instances:Array[Node] = []
var particle_scene = preload("res://Systems/Shooting/bullet_particles.tscn")
var next_id = 0


#func _ready():
	## Spawn all the instances
	#for i in TOTAL_INSTANCES:
		## instantiate and id the bullets
		#var inst = particle_scene.instantiate();
		#all_instances.append(inst)
		#add_child(inst)
		#inst.global_position = Vector3(0,-20,0);
		#inst.emitting = true
#
#func spawn(position:Vector3):
	#print(position)
	## get bullet 
	#var party = all_instances[next_id]
	## shoot bullet
	#party.activate(position)
	## iterate next id
	#next_id +=1
	#if next_id >= TOTAL_INSTANCES:
		#next_id = 0


func spawn(position:Vector3):
	var inst = particle_scene.instantiate();
	inst.global_position = position
	inst.emitting = true

