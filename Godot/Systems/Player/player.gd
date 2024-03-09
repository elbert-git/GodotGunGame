extends CharacterBody3D

# signals
signal player_damaged(new_health)

# get nodes
@onready var obj_enemy_area := $area_for_enemy
@onready var obj_invulnerable_timer := $invulnerable_timer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# player properties
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY:float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-50)
@export var TILT_UPPER_LIMIT := deg_to_rad(60)
@export var CAMERA_CONTROLLER := Camera3D

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










# --------- main functions --------------

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	_update_camera(delta)
	player_movement()
	if(!is_invulnerable):
		enemy_collision()







# --------- other functions --------------
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

func enemy_collision():
	if(len(obj_enemy_area.get_overlapping_areas()) > 0):
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
