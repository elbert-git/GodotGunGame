extends CharacterBody3D

# props
const BULLET_DAMAGE = 10.0
const SPEED = 5
const ACCEL = 10
const HEADBOB_PROPS = {
	"speed": 1.5,
	"distance_multiplier": 0.75,
	"height_reduction": -1.75,
	"distance_threshold": 8,
	"min_distance": 4,
}
var rng = RandomNumberGenerator.new()
const max_health = 100;
# references
@onready var utilities := preload('res://Systems/Utilities.gd').new()
@onready var obj_player = get_node('/root/Root').get_important_node('player')
@onready var obj_nav_agent:NavigationAgent3D = $NavigationAgent3D
@onready var obj_y_offset:Node3D = $y_offset
# states
@export var id = 0
@export var is_alive:= false;
var headbob_states = {
	"time": 0,
	"initial_y": 0,
	"offset": 0,
	"height_reduction_mix": 0
}
var health = 100;
var speed_multiplier := 1  # this prevents movement because idk why i can't change laive
var hurtbox_is_active := false










### --- signals
signal _on_enemy_hit(newHealthValue:float)
signal died_from_bullets()
signal trigger_animation(key:String)









### --- main functions
func _ready():
	# get initial y offset position
	headbob_states['initial_y'] = obj_y_offset.position.y
func _process(delta):
	if true: 
		navigate_to_player(delta);
		animate_headbob(delta);










func navigate_to_player(delta):
	# get direction
	var direction = Vector3()
	obj_nav_agent.target_position = obj_player.global_position
	direction = obj_nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	# apply movement
	velocity = velocity.lerp(direction * SPEED, ACCEL * delta) * speed_multiplier
	move_and_slide()
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
func create_spawn_position():
	var max_dist = 35
	var min_dist = 20
	var distance = rng.randf_range(min_dist, max_dist);
	var new_dir = Vector3(
		randf_range(-1.0, 1.0),
		0,
		randf_range(-1.0, 1.0)
	)
	var new_dir_normalized = new_dir.normalized()
	var new_pos = new_dir_normalized * distance
	return new_pos
func set_hurtbox_active(b:bool):
	hurtbox_is_active = b
	$y_offset/hurtbox/CollisionShape3D.call_deferred("set_disabled", !b)
	$NavAgentCollider.call_deferred('set_disabled',!b)
func triggger_death():
	print("enemy has died")
	# stop movement
	speed_multiplier = 0
	# stop colliders
	set_hurtbox_active(false)
	# start death animation
	emit_signal("trigger_animation", "death")









# --- external fucntions
func activate(): 
	# set alive
	is_alive = true
	speed_multiplier = 1
	# set position
	global_position = create_spawn_position()
	# reset health
	health = max_health
	# reset colliders
	set_hurtbox_active(true)
	emit_signal("_on_enemy_hit", health); # reset health bar
	# reset animaiotn state
	emit_signal("trigger_animation", "alive")
func deactivate():
	# set alive
	is_alive = false
	speed_multiplier = 0
	# set position
	global_position = Vector3(0, -20, 0)










# --- signal callbacks
# on bullet collision
func _on_hurtbox_area_entered(area):
	if hurtbox_is_active:
		# take damage
		# update health 
		if area.name == "area_for_enemy": # on hit with player, die
			health = 0.0 
			if(health <= 0):
				triggger_death()
		elif area.name == "Area3D": # on hit with bullet
			emit_signal("trigger_animation", "hit")
			health -= 25.0 # damage
			if(health <= 0):
				triggger_death()
				emit_signal("died_from_bullets")
		else: 
			print("error enemy does not recognise collider")
		# todo play hit animation
		# emit signal hit
		emit_signal("_on_enemy_hit", health);


func _on_enemy_mesh_death_animation_end():
	deactivate()
