extends CharacterBody3D


# signals
signal enemy_hit(health)

# enemy props
const SPEED = 2
const ACCEL = 10
const INITIAL_HEALTH = 100
const bullet_damage = 20
const distance_to_damage := 1.5

# get nodes
@onready var hurtbox:Area3D = $y_offset/hurtbox
@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var obj_y_offset := $y_offset
@onready var obj_animTree := get_node("y_offset/enemy/AnimationTree")
@onready var obj_enemy_model := get_node("y_offset/enemy")
var obj_player:CharacterBody3D = null
var obj_hook_position:Node3D = null
var obj_score_label:Label = null
var rng = RandomNumberGenerator.new()

#enemy states
@export var active:bool = false
@export var alive:bool = false
@export var hovered:bool = false
var health = 100
var initial_y_height := 0
var y_variance = 1
var y_anim_speed = 2
var y_offset := 0
var y_anim_time := 0
var y_height_reduction = -2.00


### --- main functions
func _ready():
	# get nodes
	obj_player = get_node("/root/Root/Player") as CharacterBody3D
	obj_score_label = get_node("/root/Root/Player/ui_root/score_label")
	obj_hook_position = get_node("/root/Root/Player/camRoot/Camera3D/Gun/skull_hook_point")
	initial_y_height = obj_y_offset.global_position.y
	obj_animTree.set("parameters/state/transition_request", "alive");
	set_hover(false)

func _process(delta):
	if alive:
		look_at(obj_player.global_position)
		bullet_collisions()
		float_y_offset(delta)
		navigate_to_player(delta)
		handle_player_damage()
		lerp_to_hook()






### --- other functions

func lerp_to_hook():
	if(hovered):
		set_position(obj_hook_position.global_position)

func handle_player_damage():
	# get dist
	var relative_player_pos:Vector3 = obj_player.global_position - global_position
	var dist := relative_player_pos.length()
	# if distance is closer than threhsold
	if dist < distance_to_damage:
		# call damage player
		obj_player.damage_player()
		die()
	

func bullet_collisions():
	if(len(hurtbox.get_overlapping_areas()) > 0):
		health -= bullet_damage
		# play hit animation
		obj_animTree.set("parameters/T_hitType/transition_request", "hit_" + str(rng.randi_range(1, 3))); # set random hit type
		obj_animTree.set("parameters/os_hit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
		if(health <= 0):
			# die
			die()
			# add to score
			obj_score_label.add_score(20)
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
	distance_to_player = clamp(distance_to_player, 0.00, distance_threshold)
	var lerp_factor = remap(distance_to_player, 0.00, distance_threshold, 0.00, 1.00)
	current_offset = lerp(y_height_reduction, current_offset, lerp_factor)
	# set position
	obj_y_offset.global_position = Vector3(
		obj_y_offset.global_position.x,
		initial_y_height + current_offset,
		obj_y_offset.global_position.z,
	)

func activate(pos:Vector3):
	active = true
	alive = true;
	global_position = pos
	health = INITIAL_HEALTH
	# reset helath bar
	emit_signal("enemy_hit", health)
	# reset animation tree
	obj_animTree.set("parameters/state/transition_request", "alive");

func die():
	# change state
	alive = false
	# play death animation
	obj_animTree.set("parameters/state/transition_request", "dead");
	# play death events
	$AnimationPlayer.play("death_anim_events")


func deactivate():
	# deactivate logic
	active = false
	global_position = Vector3(0,-200, 0)

func set_hover(b):
	#hovered = b
	var test_hover = $y_offset/hurtbox/hover_test
	if(b):
		test_hover.set_visible(true)
		hovered = b
	else:
		#test_hover.set_visible(false)
		pass
