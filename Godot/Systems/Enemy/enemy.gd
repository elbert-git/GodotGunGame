extends CharacterBody3D

# props
const SPEED = 2
const ACCEL = 10
const HEADBOB_PROPS = {
	"speed": 1.5,
	"distance_multiplier": 0.75,
	"height_reduction": -1.75,
	"distance_threshold": 5.8,
	"min_distance": 2,
}

# references
@onready var obj_player = get_node('/root/Root').get_important_node('player')
@onready var obj_nav_agent:NavigationAgent3D = $NavigationAgent3D
@onready var obj_y_offset:Node3D = $y_offset
@onready var utilities := preload('res://Systems/Utilities.gd').new()

# states
var headbob_states = {
	"time": 0,
	"initial_y": 0,
	"offset": 0,
	"height_reduction_mix": 0
}


### --- main functions
func _ready():
	# get initial y offset position
	headbob_states['initial_y'] = obj_y_offset.position.y

func _process(delta):
	navigate_to_player(delta)
	animate_headbob(delta)



func navigate_to_player(delta):
	# get direction
	var direction = Vector3()
	obj_nav_agent.target_position = obj_player.global_position
	direction = obj_nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	# apply movement
	velocity = velocity.lerp(direction * SPEED, ACCEL * delta)
	# move_and_slide()
	# look at player
	var look_pos = Vector3(obj_player.global_position.x, global_position.y, obj_player.global_position.z)
	look_at(look_pos)

func animate_headbob(delta):
	# iterate time 
	headbob_states['time'] += delta
	# animate y offset
	headbob_states['offset'] = (
		sin(headbob_states['time'] * HEADBOB_PROPS['speed']) * HEADBOB_PROPS['distance_multiplier']
	)
	# calculate height reduction mix by distance to player
	var distance_to_player = (obj_player.global_position - global_position).length()
	headbob_states['height_reduction_mix'] = utilities.map_range(
		distance_to_player, 
		HEADBOB_PROPS['min_distance'], HEADBOB_PROPS['distance_threshold'],
		0, 1.0,
		true
	)
	# mix between usual headbob and bob close to the player
	var final_offset = lerp(
		HEADBOB_PROPS.height_reduction,
		headbob_states['offset'],
		headbob_states['height_reduction_mix']
	)
	# apply transforms
	var curr_pos = obj_y_offset.position
	obj_y_offset.position = Vector3(
		curr_pos.x,
		headbob_states['initial_y'] + final_offset,
		curr_pos.z
	)
