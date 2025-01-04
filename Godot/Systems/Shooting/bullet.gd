extends Node3D

# --------------------------------------------------------------------------------------------- states
# get node 
@onready var Area:Area3D = get_node("Area3D")
@onready var timer:= $Timer
@onready var obj_bullet_particles_pool = get_node('/root/Root').get_important_node('bullet_particles_pool')
# Props
const SPEED = 50
const LIFESPAN:float = 3.0
@export var id:int = 0;
# states
var active:= false









## ----------------------------------------------------------------------------------- main functions
func _ready():
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		# move bullet
		position += transform.basis.z * SPEED * delta
		# on collision die
		if(len(Area.get_overlapping_bodies()) > 0):
			deactivate()






## ----------------------------------------------------------------------------------- external functions
func activate(pos:Vector3, vel:Vector3):
	global_position = pos
	look_at(global_position + vel)
	active = true
	timer.start(LIFESPAN)
func deactivate():
	# prepare to deactivate
	global_position = Vector3(0, 200, 0)
	active = false
	timer.stop()






## ----------------------------------------------------------------------------------- signal callbacks
func _on_timer_timeout():
	deactivate()
func _on_enemy_collision(area):
	deactivate()
