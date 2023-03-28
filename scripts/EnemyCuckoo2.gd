extends "res://scripts/EnemyBase.gd"

export(int) var LANDINGGRAVITY = 3.33

#takes off diagonally
#can land anywhere on a lane
#starts at the top lane then after a while goes down 
#after the floor it goes back up again
#gets stunned just like the rat

#flight levels   y = 40, 75, 120, 140
#maybe just go 25 above landing point
var time = 0.0
export var freq = 18
export var amplitude = 100
var heights = [40,75,115,140]
export var horizontalspeed = 30

var currentheight = 40
export var landing = false

onready var timer = get_node("Timer")
onready var flighttimer = get_node("flighttimer")

func _ready():
	$AnimationPlayer.play("flying")
	set_physics_process(true)
	pass # Replace with function body.

func _physics_process(delta):
	
	if(!stunned and !landing):
		Fly(delta)
	elif(landing):
		get_node("AnimationPlayer").play("landing")
		velocity.y += LANDINGGRAVITY
		move_and_slide(velocity,Vector2.UP)
		if(is_on_floor()):
			get_node("AnimationPlayer").play("standing")
			velocity.y = 0
			currentheight = position.y -10
	else:
		#just bump her like the rat and apply gravity
		velocity.y += GRAVITY
		if(!dead):
			velocity.x -= velocity.x/knockback_deceleration_stunned
		else:
			velocity.x -= velocity.x/knockback_deceleration_killed
		move_and_slide(global.VX(velocity,knockbackdirection), Vector2.UP)
	
	if(is_on_wall()):
		Flip()

func Flip():
	direction *= -1
	if(knockbackdirection != null):
		knockbackdirection *= -1
	$Sprite.flip_h = !$Sprite.flip_h

func Fly(delta):
	time += delta * freq
	var y = sin(time) * amplitude
	var velocity = Vector2(horizontalspeed * direction,y)
#	print(y)
	move_and_slide(velocity)
	
	for i in range(get_slide_count()):
		var slide = get_slide_collision(i)
		if(slide.collider.is_in_group("Players")):
			LandOnFloor()
			currentheight = position.y
		
	
	
	if(global.CloseEnough(position.y,currentheight,5)):
		LandOnFloor()
		freq = 18

func Damage(direction):
	if(!stunned): #if we aren't stunned when we are hit
		LandOnFloor()
		landing = false
		flighttimer.paused = true
		global.sfx.PlaySFX("res://SFX/enemyhurt.wav")
		stunned = true
		velocity = knockback_velocity_stunned
		knockbackdirection = direction
		$Sprite.flip_v =  true
		get_node("AnimationPlayer").play("standing")
		timer.start()
	else: #if we are already stunned when we are hit
		LandOnFloor()
		velocity = knockback_velocity_stunned  #just bump him again
		timer.wait_time = 3.0
		timer.start()




func _on_Timer_timeout():
	stunned = false
	$Sprite.flip_v = false
	timer.stop()
	get_node("AnimationPlayer").play("flying")
	freq = 1
	time = 3.14
	flighttimer.paused = false
	LandOnFloor()


func _on_StunHurtBox_body_entered(body):
	if stunned and body.is_in_group("Players"):
		flighttimer.paused = true
		global.sfx.PlaySFX("res://SFX/enemydeath.wav")
#		global.Play(preload("res://SFX/enemydeath.wav"))
		dead = true
		knockbackdirection = sign(global_position.x - body.global_position.x) 
		velocity = knockback_velocity_killed
		get_tree().create_tween().tween_property($Sprite,"rotation_degrees",-480.0,1.0)
		
		TurnOffCollision()
		emit_signal("died")

func TurnOffCollision():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("StunHurtBox/CollisionShape2D").set_deferred("disabled",true)

onready var groundcast = get_node("RayCast2D")
func GroundBelow():
	return true
	return(groundcast.is_colliding())

func _on_flighttimer_timeout():
	if(landing == true):
		#taking off
		currentheight = heights[randi() % heights.size()]
		freq = 1
		if(position.y < currentheight): # we have to go down
			time = PI/2
			GoThroughFloor()
		else:
			time = PI
		landing = false
		get_node("AnimationPlayer").play("flying")
		flighttimer.wait_time = 10.0 + (randf() * 2)
	else:
		landing = true
		flighttimer.wait_time = 5.0 + (randf() * 2)
		flighttimer.start()
		var t = get_tree().create_timer(flighttimer.wait_time/2)
		t.connect("timeout",self,"MaybeFlip")
		LandOnFloor()



func GoThroughFloor():
	set_collision_mask_bit(0,false)
	pass
func LandOnFloor():
	set_collision_mask_bit(0,true)

func MaybeFlip():
	if(randi() % 2 == 0):
		Flip()
