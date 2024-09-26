extends CharacterBody3D

# exported varialbes
@export var MOUSE_SENSITIVITY:float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-50)
@export var TILT_UPPER_LIMIT := deg_to_rad(60)
@export var CAMERA_CONTROLLER := Camera3D
# references
@onready var obj_bullet_pool = get_node('/root/Root').get_important_node('bullet_pool')
@onready var obj_bullet_spawn := get_node('camRoot/Camera3D/Gun/bulletSpawn')
@onready var obj_aim_ray_reticle := get_node('aim_ray_reticle')
@onready var obj_aim_ray :RayCast3D = get_node('camRoot/Camera3D/AimRay')
@onready var utilities := preload('res://Systems/Utilities.gd').new()
# props
const shooting_properties = {
	"fire_per_second": 15.0,
}
const cam_anim_props = {
		"y_variance": 0.1,
		"z_rot": 3.0,
		"fov_variance": 5.0,
		"shake_intensity": 20.0
}
# character properties
var health  = 100.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const JUMP_VELOCITY = 4.5
const SPEED = 8.0
# input states
var mouse_input:bool = false
var mouse_rotation:Vector3
var rotation_input:float
var tilt_input:float
var player_rotation:Vector3
var camera_rotation:Vector3
var shooting_states = {
	"fire_time": 0.0
}
var cam_anim_states = {
	"time": 0.0,
	"current_y_offset": 0.0,
	"initial_y": 0.0,
	"lerped_input_vector": Vector2(),
	"initial_fov": 0.0,
	"current_fov": 0.0,
	"initial_pos": Vector3(),
	"current_shake_intensity": 0.0
}


## --- signals
signal player_hit(newHealth:float)
signal play_sodlier_animation(animation:String)
signal player_has_died()


# --- main functions
func _ready():
	# set mouse mode centered on start
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# get initial variables
	# initial_bullet_spawn_pos = obj_bullet_spawn.position
	cam_anim_states['initial_y']= CAMERA_CONTROLLER.position.y
	cam_anim_states.initial_fov=CAMERA_CONTROLLER.fov
	cam_anim_states.initial_pos=CAMERA_CONTROLLER.position
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# processes
	update_camera(delta)
	player_movement()
	handle_shooting(delta)
	point_gun_at_center()
	camera_animations(delta)
# --- capture input events
func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
func _unhandled_input(event):
	mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		rotation_input = -event.relative.x
		tilt_input = -event.relative.y


# --- processes
func player_movement():
	# Handle jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# get input axis
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward" ,"move_backward")
	# create direction from input
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# create final velocity vector
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	# apply movement
	move_and_slide()
func update_camera(delta):
	# extract out mouse inputs
	mouse_rotation.x += tilt_input*delta*MOUSE_SENSITIVITY
	mouse_rotation.x = clamp(mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouse_rotation.y += rotation_input * delta * MOUSE_SENSITIVITY;
	# create rotation vectors to camera
	player_rotation = Vector3(0, mouse_rotation.y, 0.0)
	camera_rotation = Vector3(mouse_rotation.x, 0, 0)
	# (i think) rotate camera in x axis
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	# (i think) rotate player in y axis
	global_transform.basis = Basis.from_euler(player_rotation)
	# reset and clear rotatino inputs
	rotation_input = 0.0
	tilt_input = 0.0
func handle_shooting(delta):
	# calculate shooting vector
	var shooting_vector:Vector3 = (
		obj_bullet_spawn.global_position - obj_aim_ray_reticle.global_position
	).normalized()
	# randomize shooting vector
	shooting_vector = shooting_vector.rotated(Vector3.UP, randf_range(0.0, 0.1))
	shooting_vector = shooting_vector.rotated(Vector3.RIGHT, randf_range(0.0, 0.1))
	# shoot
	if Input.is_action_pressed("shoot") and shooting_states['fire_time']<0:
		obj_bullet_pool.shoot(
			obj_bullet_spawn.global_position,
			shooting_vector
		)
		shooting_states['fire_time'] = 1/shooting_properties.fire_per_second
		# play animation
		emit_signal("play_sodlier_animation", "shoot")
	# handle fire rate
	shooting_states['fire_time'] -= delta
func point_gun_at_center():
	if(obj_aim_ray.is_colliding()):
		var point = obj_aim_ray.get_collision_point()
		obj_aim_ray_reticle.global_position = point
	else: 
		obj_aim_ray_reticle.global_position = $camRoot/Camera3D/defaultAim.global_position
	$camRoot/Camera3D/Gun/bulletSpawn/Debug_bulletSpawnVisual.look_at(obj_aim_ray_reticle.global_position)
func camera_animations(delta):
	# get input
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward" ,"move_backward")
	cam_anim_states.lerped_input_vector = Vector2(
		lerp(cam_anim_states.lerped_input_vector.x, input_dir.x, 5.0*delta),
		lerp(cam_anim_states.lerped_input_vector.y, input_dir.y, 10.0*delta)
	)
	# iterate head bob
	cam_anim_states.time += delta * abs(cam_anim_states.lerped_input_vector.y)
	cam_anim_states.current_y_offset = sin(cam_anim_states.time * 16.0) * cam_anim_props.y_variance
	# handle camera sways
	var final_rot = cam_anim_props.z_rot * -cam_anim_states.lerped_input_vector.x
	# handle camera fov
	var fov_change = abs(cam_anim_states.lerped_input_vector.y) * cam_anim_props.fov_variance
	# handle damage shake
	cam_anim_states.current_shake_intensity = clampf(cam_anim_states.current_shake_intensity-(delta* 2.0), 0, 100.0) 
	var random_position = Vector3(
		randf_range(0.0, cam_anim_props.shake_intensity*cam_anim_states.current_shake_intensity),
		randf_range(0.0, cam_anim_props.shake_intensity*cam_anim_states.current_shake_intensity),
		cam_anim_states.initial_pos.z
	)
	var final_pos = cam_anim_states.initial_pos.lerp(random_position, 2.0*delta)
	# apply transformations
	CAMERA_CONTROLLER.position = Vector3(
		final_pos.x,
		final_pos.y + cam_anim_states.current_y_offset,
		final_pos.z,
	)
	CAMERA_CONTROLLER.rotation = Vector3(
		CAMERA_CONTROLLER.rotation.x,
		0.0,
		deg_to_rad(final_rot)
	)
	CAMERA_CONTROLLER.fov = cam_anim_states.initial_fov + fov_change

## --- signal callbacks
# enemy collision
func _on_area_for_enemy_area_entered(area):
	#trigger camera shake
	cam_anim_states.current_shake_intensity = 2.0
	print("player got hit", area.name)
	# udpate health, take damage 
	health -= 33.0
	# emit player hit to enemy signal
	emit_signal("player_hit", health)
	if health <= 0.0:
		emit_signal("player_has_died")
