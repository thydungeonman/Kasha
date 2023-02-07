extends KinematicBody2D

var velocity = Vector2.ZERO
signal knockback

export(int) var JUMP_STRENGTH = -250
export(int) var GRAVITY = 12
export(int) var ACCELERATION = 10
export(int) var FRICTION = 10
export(int) var MAX_SPEED = 70

onready var animatedSprite = $AnimatedSprite

var is_attacking = false

var knockback_dir = Vector2()
var knockback_wait = 30

var controllock = false
var direction = 0  #1 for right -1 for left 0 for not moving
var facing = 1 #1 for right -1 for left   no such thing as facing 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	if(Input.is_action_pressed("ui_right") and not controllock):
		direction = 1
		facing = 1
	elif(Input.is_action_pressed("ui_left") and not controllock):
		direction = -1
		facing = -1
	else:
		direction = 0
	
	
	
	if(Input.is_action_just_pressed("ui_action") and not controllock):
		if !is_attacking:
			is_attacking = true
			animatedSprite.frame = 0
			animatedSprite.play("Attack")
			var attack = preload("res://scenes/Attack.tscn").instance()
			controllock = true
			add_child(attack)
			attack.translate(Vector2(15* facing,0))
			attack.direction = facing
		#spawn attack scene 

		#preload will load the scene as soon as this script is loaded
		#good for things like attacks and bullets, small things
		
		
		#we attach the attack hit box to kasha
		#when a child is added it always goes to Vector2(0,0)  so right on top of its parent
		#we want the hit box to face the right direction so we move it to where we want
		
		
		#15 is just an arbitrary number
		#adjust the distance out from the player and the size of the hit box as you want
		
		
		#eventually you should have a timer that resets to 0 when an attack is made
		#and you can't attack until the timer is at least however long, maybe half a second or more
		#just so the player can't spam attacks over and over
		
		
		pass
	
	elif(Input.is_action_just_pressed("ui_action") and !is_on_floor()):
		var attack = preload("res://scenes/Attack.tscn").instance()
		add_child(attack)
		attack.translate(Vector2(15 * facing,0))
		pass
	

func _physics_process(delta):
	apply_gravity()
#	var input = Vector2.ZERO
#	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	
	if direction == 0:
		if !is_attacking:
			animatedSprite.animation = "Idle"
		apply_friction();
	else:
		apply_acceleration(direction);
		if !is_attacking:
			animatedSprite.animation = "Walk"
		if direction > 0:
			animatedSprite.flip_h = false
		elif direction < 0:
			animatedSprite.flip_h = true
	
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept") and not controllock:
			$SFXJump.play()
			velocity.y = JUMP_STRENGTH
		
	else: 
		if !is_attacking:
			animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_accept") and velocity.y < -150:
			velocity.y = -150
			
	
	velocity = move_and_slide(velocity, Vector2.UP)




func apply_gravity():
	velocity.y += GRAVITY

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	pass

func apply_acceleration(AccelValue):
	velocity.x = move_toward(velocity.x, MAX_SPEED * AccelValue, ACCELERATION)
	pass


func _on_Collision_body_entered(body):
	pass # Replace with function body.


func _on_Hurt_body_entered(body):
	if body.is_in_group("Enemies") and body.is_stunned == false:
		print("Ouch!")
	else:
		pass # Replace with function body.


func _on_AnimatedSprite_animation_finished():
	is_attacking = false
	pass # Replace with function body.
