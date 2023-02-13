extends KinematicBody2D
 
var direction = -1
export(int) var GRAVITY = 10
export var speed = 50
 
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

var velocity = Vector2()
 
onready var animated_sprite = $AnimatedSprite
# get_node("Foo") and $Foo are the same thing, one is just shorthand for the other.
onready var timer = $Timer
 
func _ready():
	# Set this on the node directly
	timer.set_wait_time(stuntime)
 
func _physics_process(_delta):
	velocity.y += GRAVITY
 
	if is_on_wall() and !stunned: #hit wall go the other way
		direction *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
	
	if(!stunned):
		velocity.x = speed
		if(is_on_floor()): #on floor  reset vertical velocity
			velocity.y = 0
		move_and_slide(global.VX(velocity,direction), Vector2.UP)
		
	else: #we're stunned
		#we are going to want to reduce horizontal velocity each frame
		if(!dead):
			velocity.x -= velocity.x/knockback_deceleration_stunned
		else:
			velocity.x -= velocity.x/knockback_deceleration_killed
		move_and_slide(global.VX(velocity,knockbackdirection), Vector2.UP)
 
	
 
func TrueVelocity():
	var v = velocity
	v.x *= direction
	return v

#called by the attack scene when it overlaps with an enemy body
#the direction parameter is passed from the player to the attack scene and then to the rat 
#so we know which direction the rat was hit from
func Damage(direction):
	if(!stunned): #if we aren't stunned when we are hit
		stunned = true
		velocity = knockback_velocity_stunned
		knockbackdirection = direction
		animated_sprite.flip_v = !animated_sprite.flip_v
		timer.start()
	else: #if we are already stunned when we are hit
		velocity = knockback_velocity_stunned  #just bump him again
		timer.wait_time = 3.0
		timer.start()
 
func _on_Timer_timeout():
	stunned = false
	animated_sprite.flip_v = !animated_sprite.flip_v
	timer.stop()
 
func _on_StunHurtbox_body_entered(body):
	if stunned and body.is_in_group("Players"):
		dead = true
		knockbackdirection = sign(global_position.x - body.global_position.x) 
		velocity = knockback_velocity_killed
		get_tree().create_tween().tween_property(animated_sprite,"rotation_degrees",-480.0,1.0)
		
		TurnOffCollision()
		
 
func _on_Attack_knockback():
	print ("Knockback")

func TurnOffCollision():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("StunHurtbox/CollisionShape2D").set_deferred("disabled",true)


func Flip():
	direction *= -1
	animated_sprite.flip_h = !animated_sprite.flip_h
