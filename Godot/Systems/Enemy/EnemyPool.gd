extends Node3D

# get nodes
var bullet_scene = preload("res://Systems/Enemy/enemy.tscn")
@onready var timer = $Timer
var rng = RandomNumberGenerator.new()
# constants - props
const TOTAL_INSTANCES:int = 10
const SPAWN_INTERVAL:float = 3.0
# vars - states
var all_instances:Array[CharacterBody3D] = []
var next_id:int = 0


## --- signals
signal enemy_has_died()

#------------- main funcs
func _ready():
	# spawn instances
	for i in TOTAL_INSTANCES:
		# instanciate
		var inst = bullet_scene.instantiate()
		inst.id = i
		add_child(inst)
		# deactivate
		inst.deactivate()
		# listen to instance death
		inst.died_from_bullets.connect(on_died_from_bullets)
		# append to array
		all_instances.append(inst)
	# start spawn loop
	timer.start(SPAWN_INTERVAL)


#------------- other funcs
func spawn_available_enemy():
	# get available enemy
	var curr_enemy = null
	for i in TOTAL_INSTANCES:
		var e = all_instances[i]
		if e.is_alive == false:
			curr_enemy = e
			break
	# spawn if available
	if curr_enemy != null:
		curr_enemy.activate()


# --- signal callbacks
func on_died_from_bullets():
	emit_signal("enemy_has_died")
func _on_timer_timeout():
	spawn_available_enemy()
	timer.start(SPAWN_INTERVAL)
