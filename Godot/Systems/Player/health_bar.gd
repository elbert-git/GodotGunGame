extends Control

# get elements
@onready var el_health_bar = $fill
@onready var el_health_bg = $bg

# get variables
var health_full_size = 100
var current_health_percent = 100

func _ready():
	# get full health bar size in pixels
	health_full_size =  el_health_bg.size.x
	# set health bar for first frame
	set_health_bar(current_health_percent)

func set_health_bar(percent):
	# set variable
	current_health_percent = percent
	# get new size
	var new_size = health_full_size * percent/100
	# set new size
	el_health_bar.size.x = new_size


func _on_player_player_damaged(new_health):
	set_health_bar(new_health)
