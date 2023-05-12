extends "res://scripts/Attack.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func Count(delta):
	count += 1
	if(count == 2):
		monitoring = true
		show()


func Collide():
	if(monitoring):
		for body in get_overlapping_bodies():
			if(body.is_in_group("Egg")):
				get_parent().root.travel("attack recoil")
				get_parent().Hforces.push_back(Vector3(30,6,-direction))
				body.get_node("AudioStreamPlayer").play()
				body.direction = direction
				body.velocity.x += eggpushvelocity 
				body.get_node("rolltimer").start()
				get_parent().controllock = false
				get_parent().attack = null
				get_parent().attacking = false
				print("egg")
				print(str(body.get_node("eggtimer").time_left))
				body.get_node("eggtimer").stop()
				body.get_node("eggtimer").start()
				print(str(body.get_node("eggtimer").time_left))
				queue_free()
				return
				pass
			if body.is_in_group("Enemies"):
				global.SlowDown(slowdowntme,slowdownscale)
				body.Damage(direction,Vector2(200,-200))
				emit_signal("knockback") 
				set_physics_process(false) 
#				if(!get_parent().rapidattacking):
				get_parent().controllock = false
				get_parent().attack = null
				queue_free()
