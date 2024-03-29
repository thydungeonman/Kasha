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
var freqtemp 
export var amplitude = 100
var heights = [40,75,115,147]
export var horizontalspeed = 30

var currentheight = 40
export var landing = false

onready var timer = get_node("Timer")
onready var flighttimer = get_node("flighttimer")
var egg = null

func _ready():
	freqtemp = freq
	$AnimationPlayer.play("flying")
	set_physics_process(true)
	

func _physics_process(delta):
	OutOfBoundsCheck()
	
	if(layingegg):
		egg = load("res://scenes/EnemyEgg.tscn").instance()
		move_and_collide(Vector2(0,-30))
		egg.position = position + Vector2(0,20) 
		get_parent().add_child(egg)
		var oldpos = position
		
		layingegg = false
	
	
	if(landing and is_on_floor()):
		MaybeFlip()
	
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
		if(is_on_floor()):
			velocity.y = 0
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
		freq = freqtemp

func Damage(direction,newvelocity = null):
	if(!stunned): #if we aren't stunned when we are hit
		LandOnFloor()
		landing = false
		flighttimer.paused = true
		global.sfx.PlaySFX("res://SFX/enemyhurt.wav")
		stunned = true
		if(newvelocity != null):
			velocity = newvelocity
		else:
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
	if stunned and body.is_in_group("Players") or (body.is_in_group("Egg") and body.velocity.x > 1):
		flighttimer.paused = true
		timer.paused = true
		global.sfx.PlaySFX("res://SFX/enemydeath.wav")
#		global.Play(preload("res://SFX/enemydeath.wav"))
		dead = true
		knockbackdirection = sign(global_position.x - body.global_position.x) 
		velocity = knockback_velocity_killed
		get_tree().create_tween().tween_property($Sprite,"rotation_degrees",-480.0,1.0)
		
		TurnOffCollision()
		emit_signal("died")
		Die()

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
			GoThroughFloor()#this needs to be on both so the egg doesn't get hit
			time = PI
		landing = false
		get_node("AnimationPlayer").play("flying")
		flighttimer.stop()
		flighttimer.wait_time = 10.0 + (randf() * 2)
		flighttimer.start()
		if(egg != null):
			set_collision_mask_bit(4,false)
	else:
		landing = true
		flighttimer.stop()
		flighttimer.wait_time = 5.0 + (randf() * 2)
		flighttimer.start()
		var t = get_tree().create_timer(5)
		t.connect("timeout",self,"SpawnEgg",[],CONNECT_ONESHOT)
		
		LandOnFloor()


func GoThroughFloor():
	set_collision_mask_bit(0,false)
	pass
func LandOnFloor():
	set_collision_mask_bit(0,true)

func MaybeFlip():
	if(randi() % 120 == 0):
		Flip()


var layingegg = false
func SpawnEgg():
	layingegg = true
	set_collision_mask_bit(4,true)
