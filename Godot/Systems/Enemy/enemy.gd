extends CharacterBody3D

# signals
signal enemy_hit(health)

# enemy props
const SPEED = 2
const ACCEL = 10
const INITIAL_HEALTH = 100

# get nodes
@onready var hurtbox:Area3D = $y_offset/hurtbox
@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var obj_y_offset := $y_offset
var obj_player:CharacterBody3D = null

#enemy states
@export var active = false
var health = 100
var initial_y_height := 0
var y_variance = 2
var y_anim_speed = 2
var y_offset := 0
var y_anim_time := 0


### --- main functions
func _ready():
	obj_player = get_node("/root/Root/Player") as CharacterBody3D
	initial_y_height = obj_y_offset.global_position.y

func _process(delta):
	if active:
		bullet_collisions()
		float_y_offset(delta)
		navigate_to_player(delta)






### --- other functions
func bullet_collisions():
	if(len(hurtbox.get_overlapping_areas()) > 0):
		health -= 20
		if(health <= 0):
			deactivate()
		emit_signal("enemy_hit", health)

func navigate_to_player(delta):
	var direction = Vector3()
	nav.target_position = obj_player.global_position
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * SPEED, ACCEL * delta)
	move_and_slide()

func float_y_offset(delta):
	# update timer
	y_anim_time +=1
	# calculate y variance
	var current_offset = sin(y_anim_time * y_anim_speed * delta) * y_variance
	# - when close to player
	var distance_to_player = global_position.distance_to(obj_player.global_position)
	var distance_threshold = 10.00
	var height_reduction = -4.00
	distance_to_player = clamp(distance_to_player, 0.00, distance_threshold)
	var lerp_factor = remap(distance_to_player, 0.00, distance_threshold, 0.00, 1.00)
	current_offset = lerp(height_reduction, current_offset, lerp_factor)
	# set position
	obj_y_offset.global_position = Vector3(
		obj_y_offset.global_position.x,
		initial_y_height + current_offset,
		obj_y_offset.global_position.z,
	)

func activate(pos:Vector3):
	active = true
	global_position = pos
	health = INITIAL_HEALTH

func deactivate():
	active = false
	global_position = Vector3(0,-200, 0)
