extends Node

signal death_animation_end()

@onready var animation_tree:AnimationTree = $AnimationTree
@export var obj_timer:Timer = null 

func _on_enemy_trigger_animation(key):
	match key:
		"death":
			# play animations
			animation_tree.set("parameters/state/transition_request", "dead")
			# start timer to 
			obj_timer.start(0.5)
		"alive":
			animation_tree.set("parameters/state/transition_request", "alive")
		_:
			print("unknown animations key")


func _on_timer_timeout():
	emit_signal("death_animation_end")
