extends Node3D

const important_node_paths = {
	"player": "Player",
	"bullet_pool": "BulletPool",
	"enemy_pool": "EnemyPool"
}


func _ready():
	pass
func _physics_process(delta):
	pass
func game_start():
	# reset all variables
	pass
func game_over():
	# stop game and show game over screen
	pass


# --- external functions
func get_important_node(key):
	return get_node(important_node_paths[key])
