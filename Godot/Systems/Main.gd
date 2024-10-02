extends Node3D

const important_node_paths = {
	"player": "Player",
	"bullet_pool": "BulletPool",
	"enemy_pool": "EnemyPool",
	"bullet_particles_pool": "BulletParticlePool"
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
	print("game over triggered")
	pass


# --- external functions
func get_important_node(key):
	return get_node(important_node_paths[key])


func _on_player_player_has_died():
	game_over()
