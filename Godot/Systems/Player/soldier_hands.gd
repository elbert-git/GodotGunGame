extends Node

@onready var obj_animation_tree := $AnimationTree

func _on_player_play_sodlier_animation(animation:String):
	match(animation):
		"shoot":
			obj_animation_tree.set("parameters/os_shoot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		_:
			print("unknown animation", animation)

