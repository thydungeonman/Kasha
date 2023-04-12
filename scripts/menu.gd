extends Node2D



#need flag for when we start attacking on the floor or in the air


func _on_mode1_pressed():
	get_tree().change_scene("res://scenes/world.tscn")
	pass # Replace with function body.


func _on_mode2_pressed():
	get_tree().change_scene("res://scenes/world2.tscn")
	pass # Replace with function body.


func _on_test_pressed():
	get_tree().change_scene("res://scenes/test.tscn")
	pass # Replace with function body.
