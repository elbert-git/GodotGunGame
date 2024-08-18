extends CharacterBody3D

# enemy props
const SPEED = 2
const ACCEL = 10

# references
@onready var obj_player = get_node('/root/Root').get_important_node('player')
@onready var obj_nav_agent:NavigationAgent3D = $NavigationAgent3D



### --- main functions
func _ready():
	pass
	# print(player)

func _process(delta):
	navigate_to_player(delta)



func navigate_to_player(delta):
	# get direction
	var direction = Vector3()
	obj_nav_agent.target_position = obj_player.global_position
	direction = obj_nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	# apply movement
	velocity = velocity.lerp(direction * SPEED, ACCEL * delta)
	move_and_slide()
	# look at player
	look_at(obj_player.global_position)
