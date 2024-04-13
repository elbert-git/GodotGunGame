extends Node3D

# get nodes
var bullet_scene = preload("res://Systems/Enemy/enemy.tscn")
@onready var timer = $Timer
var rng = RandomNumberGenerator.new()

# constants - props
const TOTAL_INSTANCES:int = 3
const SPAWN_INTERVAL:float = 3.0

# vars - states
var all_instances:Array[CharacterBody3D] = []
var next_id:int = 0

#------------- main funcs
func _ready():
	# spawn instances
	for i in TOTAL_INSTANCES:
		# instanciate
		var inst = bullet_scene.instantiate()
		add_child(inst)
		# deactivate
		inst.deactivate()
		# append to array
		all_instances.append(inst)
	# start spawn loop
	timer.start(SPAWN_INTERVAL)


#------------- other funcs
func spawn_enemy():
	# get available enemy
	var curr_enemy = null
	for i in TOTAL_INSTANCES:
		var e = all_instances[i]
		if e.active == false:
			curr_enemy = e
			break
	# spawn if available
	if curr_enemy != null:
		curr_enemy.activate(create_spawn_position())

func create_spawn_position():
	var max_dist = 35
	var min_dist = 20
	var distance = rng.randf_range(min_dist, max_dist)
	var new_dir = Vector3(
		randf_range(-1.0, 1.0),
		0,
		randf_range(-1.0, 1.0)
	)
	var new_dir_normalized = new_dir.normalized()
	var new_pos = new_dir_normalized * distance
	return new_pos


func _on_timer_timeout():
	spawn_enemy()
	timer.start(SPAWN_INTERVAL)
