extends Node

signal death_animation_end()

@onready var animation_tree:AnimationTree = $AnimationTree


func _on_enemy_trigger_animation(key):
	match key:
		"death":
			animation_tree.set("parameters/state/transition_request", "dead")
		"alive":
			animation_tree.set("parameters/state/transition_request", "alive")
		_:
			print("unknown animations key")
