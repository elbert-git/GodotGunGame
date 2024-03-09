extends Node3D

# props
var full_size = 100
var size = 100

# get nodes
var obj_player = null
@onready var obj_fill = $fill


# main functions
func _ready():
	obj_player = get_node("/root/Root/Player")
	full_size = obj_fill.scale.x
	print(full_size)

func _process(delta):
	look_at(obj_player.position)


func _on_enemy_enemy_hit(health):
	var new_size = health/100.00
	obj_fill.scale.x = full_size * new_size
