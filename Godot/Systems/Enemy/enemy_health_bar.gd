extends Node3D

## --- variables
# props
var full_size = 100
var size = 100
# get nodes
var obj_player = null
@onready var obj_fill = $fill


## ---  main functions
func _ready():
	obj_player = get_node("/root/Root/Player")
	full_size = obj_fill.scale.x
func _process(delta):
	look_at(obj_player.position)


func _on_enemy__on_enemy_hit(newHealthValue):
	# calc new size
	var new_size = newHealthValue/100.00
	# prevent negative size
	new_size = clamp(new_size, 0, 1)
	# apply change to health bar
	obj_fill.scale.x = full_size * new_size
