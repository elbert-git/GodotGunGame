extends Node3D

# signals
signal enemy_hit()

# get node 
@onready var Area:Area3D = get_node("Area3D")
@onready var timer:= $Timer

# Props
const SPEED = 20
const LIFESPAN:float = 3.0
@export var id:int = 0;

# states
var active:= false

# Called when the node enters the scene tree for the first time.
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

func activate(pos:Vector3, vel:Vector3):
	global_position = pos
	look_at(global_position + vel)
	active = true
	timer.start(LIFESPAN)

func deactivate():
	global_position = Vector3(0, -20, 0)
	active = false
	timer.stop()


func _on_timer_timeout():
	deactivate()
