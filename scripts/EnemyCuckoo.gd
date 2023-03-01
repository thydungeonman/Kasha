extends KinematicBody2D

signal died

var flyfreq = 1
export var freq = 18
export var amplitude = 100

var time = 0.0
var direction = -1
var horizontalspeed = 30

var hitstun = 0
var health = 1
var stunned = false
var dead = false

export var knockback_velocity_stunned = Vector2(100,-150)
export var knockback_velocity_killed = Vector2(150,-200)

export var knockback_deceleration_stunned = 20
export var knockback_deceleration_killed = 100

var knockbackdirection = 0
var stuntime = 3.0
export(int) var GRAVITY = 10

#takes off diagonally
#can land anywhere on a lane
#starts at the top lane then after a while goes down 
#after the floor it goes back up again
#gets stunned just like the rat

#flight levels   y = 40, 75, 120, 140

var currentheight = 40
export var landing = false
var velocity = Vector2()
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
		velocity.y += GRAVITY
		move_and_slide(velocity,Vector2.UP)
		if(is_on_floor()):
			get_node("AnimationPlayer").play("standing")
			velocity.y = 0
		
		
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
	$Sprite.flip_h = !$Sprite.flip_h


func Fly(delta):
	time += delta * freq
	var y = sin(time) * amplitude
	var velocity = Vector2(horizontalspeed * direction,y)
#	print(y)
	move_and_slide(velocity)
	if(global.CloseEnough(position.y,currentheight,5)):
		freq = 18

func Damage(direction):
	if(!stunned): #if we aren't stunned when we are hit
		flighttimer.paused = true
		global.sfx.PlaySFX("res://SFX/enemyhurt.wav")
		stunned = true
		velocity = knockback_velocity_stunned
		knockbackdirection = direction
		$Sprite.flip_v =  true
		get_node("AnimationPlayer").play("standing")
		timer.start()
	else: #if we are already stunned when we are hit
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


func _on_stunbox_body_entered(body):
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
	pass # Replace with function body.
func TurnOffCollision():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("stunbox/CollisionShape2D").set_deferred("disabled",true)

onready var groundcast = get_node("RayCast2D")
func GroundBelow():
	return(groundcast.is_colliding())



func _on_flighttimer_timeout():
	if(landing == true):
		#taking off
		freq = 1
		time = 3.14
		landing = false
		get_node("AnimationPlayer").play("flying")
	else:
		if(GroundBelow()):
			landing = true
			flighttimer.wait_time = 3.0
			flighttimer.start()
			
	
	pass # Replace with function body.
