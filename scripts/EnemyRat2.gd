extends "res://scripts/EnemyBase.gd"


onready var sprite = $Sprite
onready var timer = $Timer

onready var root = get_node("AnimationTree").get("parameters/playback")

func _ready():
	# Set this on the node directly
	root.start("idle")
	set_physics_process(true)
	if(randi() % 2 == 1):
		Flip()
	timer.set_wait_time(stuntime)


func _physics_process(delta):
	velocity.y += GRAVITY
 
	if is_on_wall() and !stunned: #hit wall go the other way
		direction *= -1
		sprite.flip_h = !sprite.flip_h
	
	if(!stunned):
		velocity.x = speed
		if(is_on_floor()): #on floor  resset vertical velocity
			velocity.y = 0
		move_and_slide(global.VX(velocity,direction), Vector2.UP)
		
	else: #we're stunned
		#we are going to want to reduce horizontal velocity each frame
		
		if(!dead):
			velocity.x -= velocity.x/knockback_deceleration_stunned
		else:
			velocity.x -= velocity.x/knockback_deceleration_killed
		move_and_slide(global.VX(velocity,knockbackdirection) * 60 * delta * (1/Engine.time_scale), Vector2.UP)
	pass
	Animate()



#called by the attack scene when it overlaps with an enemy body
#the direction parameter is passed from the player to the attack scene and then to the rat 
#so we know which direction the rat was hit from
func Damage(direction,newvelocity = null):
	if(!stunned): #if we aren't stunned when we are hit
		global.sfx.PlaySFX("res://SFX/enemyhurt.wav")
#		global.Play(preload("res://SFX/enemyhurt.wav"))
		stunned = true
		if(newvelocity != null):
			velocity = newvelocity
		else:
			velocity = knockback_velocity_stunned
		knockbackdirection = direction
		sprite.flip_v = !sprite.flip_v
		timer.start()
	else: #if we are already stunned when we are hit
		velocity = knockback_velocity_stunned  #just bump him again
		timer.wait_time = 3.0
		timer.start()


 
func _on_Attack_knockback():
	print ("Knockback")

func TurnOffCollision():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("StunHurtBox/CollisionShape2D").set_deferred("disabled",true)


func _on_Timer_timeout():
	stunned = false
	sprite.flip_v = !sprite.flip_v
	timer.stop()
	pass # Replace with function body.


func _on_StunHurtBox_body_entered(body):
	if stunned and body.is_in_group("Players"):
		global.sfx.PlaySFX("res://SFX/enemydeath.wav")
#		global.Play(preload("res://SFX/enemydeath.wav"))
		dead = true
		knockbackdirection = sign(global_position.x - body.global_position.x) 
		velocity = knockback_velocity_killed
		get_tree().create_tween().tween_property(sprite,"rotation_degrees",-480.0,1.0)
		
		TurnOffCollision()
		emit_signal("died")
		Die()
	pass # Replace with function body.



func Animate():
	
	#if not stunned and moving:
	#run
#	else:
#	idle
	if(!stunned and velocity.x != 0):
#		print("walking")
		root.travel("walk")
#		$AnimationPlayer.play("walk")
	else:
		root.travel("idle")
#		$AnimationPlayer.play("idle")


	
	pass
