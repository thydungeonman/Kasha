extends KinematicBody2D

signal died

#base enemy variables

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
export var stuntime = 3.0


var velocity = Vector2()


func _ready():
	pass # Replace with function body.

func Flip():
	direction *= -1
	if(knockbackdirection != null):
		knockbackdirection *= -1
	$Sprite.flip_h = !$Sprite.flip_h

func Damage(dir):
	pass

func TrueVelocity():
	var v = velocity
	v.x *= direction
	return v

func Die():
#	set_physics_process(false)
	get_tree().create_timer(2.0,true).connect("timeout",self,"ActuallyDie")

func ActuallyDie():
	call_deferred("queue_free")
