extends Node3D

# get nodes
var bullet_scene = preload("res://Systems/Shooting/bullet.tscn")

# props
const TOTAL_INSTANCES = 100

# states
var all_instances:Array[Node3D] = []
var next_id:= 1






func _ready():
	# on start create number of instances
	for i in TOTAL_INSTANCES:
		# instantiate and id the bullets
		var inst = bullet_scene.instantiate();
		inst.id = i
		all_instances.append(inst)
		add_child(inst)
		inst.global_position = Vector3(0,-20,0);





# ------------------ other functions
func shoot(pos:Vector3, vel:Vector3):
	# get bullet 
	var bullet = all_instances[next_id]
	# shoot bullet
	bullet.activate(pos, vel)
	# iterate next id
	next_id +=1
	if next_id >= TOTAL_INSTANCES:
		next_id = 0
