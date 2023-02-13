extends Node2D


func _ready():
	pass # Replace with function body.


func _on_Timer_timeout():
	
	var rat = load("res://scenes/EnemyRat.tscn").instance()
	add_child(rat)
	rat.translate(Vector2(330,20))
	if(randi() % 2 == 1):
		rat.Flip()
	

