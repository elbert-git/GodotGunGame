extends Node3D

# get node refs
@onready var Area:Area3D = get_node("Area3D")

const SPEED = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# move bullet
	position += transform.basis.z * SPEED * delta
	# on collision die
	if(len(Area.get_overlapping_bodies()) > 0):
		queue_free()
	
