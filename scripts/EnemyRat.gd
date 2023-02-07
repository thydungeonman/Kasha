extends KinematicBody2D
 
export var direction = Vector2.LEFT
export(int) var GRAVITY = 12
export(int) var KNOCKBACK_STRENGTH = -150
 
var hitstun = 0
var health = 1
var is_stunned = false
var knockback_velocity = Vector2(100,50)
var stuntime = 3
 
# This is redundant, KinematicBody2D already has a velocity of 0 to start with
var velocity = Vector2.ZERO
 
onready var animated_sprite = $AnimatedSprite
# get_node("Foo") and $Foo are the same thing, one is just shorthand for the other.
onready var timer = $Timer
 
func _ready():
	# Set this on the node directly
	timer.set_wait_time(stuntime)
 
func _physics_process(_delta):
	velocity.y += GRAVITY
 
	if is_on_wall():
		direction *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
 
	if(!is_stunned):
		velocity = direction * 50
 
	move_and_slide(velocity, Vector2.UP)
 
# No idea what calls this, might need to be done differently
# If this is called by the player script, with an Area2d collision signal, then the signal could be from EnemyHurtbox -> Enemy instead of WeaponHitbox -> Player (which calls Enemy)
func Damage(direction):
	is_stunned = true
	velocity = Vector2(0, KNOCKBACK_STRENGTH)
	animated_sprite.flip_v = !animated_sprite.flip_v
	timer.start()
 
func _on_Timer_timeout():
	is_stunned = false
	animated_sprite.flip_v = !animated_sprite.flip_v
	timer.stop()
 
func _on_StunHurtbox_body_entered(body):
	if is_stunned and body.is_in_group("Players"):
		var knockback_direction = sign(body.global_position.x - global_position.x) 
		velocity = knockback_velocity
		velocity.y *= knockback_direction
		get_node("CollisionShape2D").set_deferred("disabled", true)
 
func _on_Attack_knockback():
	print ("Knockback")
