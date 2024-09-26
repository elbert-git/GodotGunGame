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
		"hit":
			print(randi_range(0,3))
			var type = randi_range(0, 3) + 1
			# set hit type
			animation_tree["parameters/T_hitType/transition_request"] = "hit_" + str(type)
			# trigger hit shots
			animation_tree["parameters/os_hit/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		_:
			print("unknown animations key")


func _on_timer_timeout():
	emit_signal("death_animation_end")


func _on_enemy__on_enemy_hit(newHealthValue):
	$flash_anim_player.stop(true)
	$flash_anim_player.play("flash")
