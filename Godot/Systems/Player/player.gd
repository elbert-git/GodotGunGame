extends CharacterBody3D

# signals
signal player_damaged(new_health)
signal player_shoots()

# get nodes
@onready var obj_enemy_area := $area_for_enemy
@onready var obj_invulnerable_timer := $invulnerable_timer
@onready var obj_bullet_pool:= get_node("/root/Root/Pools/BulletPool")
@onready var obj_aimRayDebugReticle:= $debug_aimRayReticle
@onready var obj_aimRay := $camRoot/Camera3D/AimRay
@onready var obj_defaultAimPosition := $camRoot/Camera3D/defaultAim
@onready var obj_gunRoot := $camRoot/Camera3D/Gun
@onready var obj_bullet_spawn := $camRoot/Camera3D/Gun/bulletSpawn
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# player properties
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY:float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-50)
@export var TILT_UPPER_LIMIT := deg_to_rad(60)
@export var CAMERA_CONTROLLER := Camera3D
const FIRE_RATE_PER_SECOND:float = 15
var rng = RandomNumberGenerator.new()

# input Variables
var _mouse_input:bool = false
var _mouse_rotation:Vector3
var _rotation_input:float
var _tilt_input:float
var _player_rotation:Vector3
var _camera_rotation:Vector3

# player states
var health = 100
var is_invulnerable = false
var time_since_last_shot = 0.0
var initial_bullet_spawn_pos = Vector3.ZERO;
var prev_skull = null







# --------- main functions --------------

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	initial_bullet_spawn_pos = obj_bullet_spawn.position

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# processes
	_update_camera(delta)
	player_movement()
	point_gun_at_center()
	handle_shooting(delta)







# --------- other functions --------------
func point_gun_at_center():
	# default aim
	var aim_pos:Vector3 = obj_defaultAimPosition.global_position;
	# unhover skull
	if(prev_skull != null):
		prev_skull.set_hover(false)
	# if ray collides set new aim
	if obj_aimRay.is_colliding():
		aim_pos = obj_aimRay.get_collision_point()
		# hover current skull if it's there 
		var hit_object = obj_aimRay.get_collider()
		if(hit_object.get_name() == "hurtbox"):
			# get skull and add hover
			var skull = hit_object.get_parent().get_parent()
			skull.set_hover(true)
			prev_skull = skull
		
	# aim the gun
	obj_gunRoot.look_at(aim_pos)
	# debug posiition of gun
	obj_aimRayDebugReticle.global_position = aim_pos

func handle_shooting(delta):
	# iterate time
	time_since_last_shot += delta
	if Input.is_action_pressed("shoot") and time_since_last_shot > 1.0/FIRE_RATE_PER_SECOND:
		var bullet_vel = obj_bullet_spawn.global_basis.z
		obj_bullet_pool.shoot(obj_bullet_spawn.global_position, bullet_vel)
		time_since_last_shot = 0.0
	# randomise bullet spawn position;
	var offset_pos = Vector3(
		rng.randf_range(-1.0, 1.0),
		rng.randf_range(-1.0, 1.0),
		0
	)
	obj_bullet_spawn.position = initial_bullet_spawn_pos + offset_pos

# escape event
func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x
		_tilt_input = -event.relative.y

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input*delta*MOUSE_SENSITIVITY
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta * MOUSE_SENSITIVITY;
	
	_player_rotation = Vector3(0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0, 0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func player_movement():
		# Handle jump.	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward" ,"move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func damage_player():
		if(!is_invulnerable):
			# change own health variable
			health -= 20 # damage by 20
			# emit health damage signal
			emit_signal("player_damaged", health)
			# be invulnerable for awhile
			is_invulnerable = true
			obj_invulnerable_timer.start(3)




# --------- signal callbacks --------------


func _on_invulnerable_timer_timeout():
	is_invulnerable = false
