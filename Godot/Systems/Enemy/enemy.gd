extends CharacterBody3D

# signals
signal enemy_hit(health)

# get nodes
@onready var area:Area3D = $Area3D

#enemy states
var health = 100


func _ready():
	pass

func _process(delta):
	if(len($Area3D.get_overlapping_areas()) > 0):
		health -= 20
		if(health <= 0):
			queue_free()
		emit_signal("enemy_hit", health)
