extends Node3D

# load bullet
var bullet_scene = preload("res://Systems/Shooting/bullet.tscn")

# node reference
@onready var AIM_RAY:RayCast3D = get_node("../AimRay");
@onready var CAMERA:Camera3D = $"..";

var fire_rate = 10.0
var bullet_downtime = 1/fire_rate

# ------ main funcs
func _ready():
	# make aim ray ignore player body
	AIM_RAY.add_exception(get_node("../../.."));

func _process(delta):
	# iterate bullet downtime
	bullet_downtime -= delta
	# aim gun at center
	point_gun_at_center()
	# listen for shoot input
	if(Input.is_action_pressed("shoot") && bullet_downtime < 0):
		instantiate_bullet()
		bullet_downtime = 1/fire_rate


# ----- other funcs: 
func instantiate_bullet():
	# get root
	var root = get_tree().root
	# get spawn position and rotation
	var spawn_pos = $bulletSpawn.global_position
	# instatiate
	var instance = bullet_scene.instantiate()
	root.add_child(instance)
	# set position and rotation
	instance.global_position = spawn_pos
	instance.look_at(to_global(transform.basis.x))

func point_gun_at_center():
	# default aim
	var aim_pos:Vector3 = get_node("../defaultAim").global_position;
	# if ray collides set new aim
	if AIM_RAY.is_colliding():
		aim_pos = AIM_RAY.get_collision_point()
	# aim the gun
	look_at(aim_pos)
