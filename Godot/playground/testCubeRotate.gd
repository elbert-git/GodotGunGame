extends MeshInstance3D

signal test_ping(number)

func _on_button_button_down():
	rotate(Vector3(0,1,0), 20)
	print("emitting signal health")
	emit_signal("test_ping", 20)
