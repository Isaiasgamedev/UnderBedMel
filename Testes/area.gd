extends Area2D



func _on_area_body_entered(body):
	if body.name == "Player":
		body.hab1 = 1
		queue_free()
