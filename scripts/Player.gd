extends KinematicBody2D

var velocity = Vector2.ZERO
signal knockback

onready var root = get_node("AnimationTree").get("parameters/playback")
onready var flashroot = get_node("AnimationTree2").get("parameters/playback")

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

export var health = 3
var stunned = false
export var invincibletime = .5
var invincibletimer = 0.0 #might just use a regular timer though
var invincible = false
# Called when the node enters the scene tree for the first time.
func _ready():
	root.start("idle")
	flashroot.start("RESET")
	pass # Replace with function body.


func GoThroughFloor():
	print("done")
	set_collision_mask_bit(0,true)

var t
func _process(delta):
	
	
	if(Input.is_action_pressed("ui_right") and not controllock):
		direction = 1
		facing = 1
	elif(Input.is_action_pressed("ui_left") and not controllock):
		direction = -1
		facing = -1
	else:
		direction = 0
	
	if(Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_accept")):
		for i in range(get_slide_count()):
			var col = get_slide_collision(i)
			if(col.collider).is_in_group("notfloor"):
				t = get_tree().create_timer(.3,true)
				t.connect("timeout",self,"GoThroughFloor",[],CONNECT_ONESHOT)
				set_collision_mask_bit(0,false)
				pass
		pass
	
	
	if(Input.is_action_just_pressed("ui_action") and not controllock):
		if !is_attacking:
			is_attacking = true
#			animatedSprite.frame = 0
#			animatedSprite.play("Attack")
			var attack = preload("res://scenes/Attack.tscn").instance()
			controllock = true
			add_child(attack)
			attack.translate(Vector2(15* facing,0))
			attack.direction = facing
			t = get_tree().create_timer(.4)
			t.connect("timeout",self,"StopAttacking",[t],CONNECT_ONESHOT)
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
		
		
		
	
	elif(Input.is_action_just_pressed("ui_action") and !is_on_floor()):
		var attack = preload("res://scenes/Attack.tscn").instance()
		add_child(attack)
		attack.translate(Vector2(15 * facing,0))
		
	
	
	Anims()
	

func StopAttacking(t):
	is_attacking = false
	

func StopInvincible():
	invincible = false
	$invinciblelabel.hide()
	flashroot.travel("RESET")

func _physics_process(delta):
	apply_gravity()
	
	if(stunned and velocity.x == 0):
		stunned = false
		controllock = false
		t = get_tree().create_timer(invincibletime)
		t.connect("timeout",self,"StopInvincible",[],CONNECT_ONESHOT)
	
	
	
	
	if direction == 0:
#		if !is_attacking:
#			animatedSprite.animation = "Idle"
		apply_friction();
	else:
		apply_acceleration(direction);
#		if !is_attacking:
#			animatedSprite.animation = "Walk"
		if direction > 0:
			$Sprite.flip_h = false
		elif direction < 0:
			$Sprite.flip_h = true
	
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept") and not controllock and !Input.is_action_pressed("ui_down"):
			global.Play(preload("res://SFX/kashajump.wav"))
			velocity.y = JUMP_STRENGTH
		
	else: 
#		if !is_attacking:
#			animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_accept") and velocity.y < -150:
			velocity.y = -150
			
	
	velocity = move_and_slide(velocity, Vector2.UP)




func apply_gravity():
	velocity.y += GRAVITY

func apply_friction():
	if(!stunned):
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	else:
		velocity.x = move_toward(velocity.x,0,2.5)
	pass

func apply_acceleration(AccelValue):
	velocity.x = move_toward(velocity.x, MAX_SPEED * AccelValue, ACCELERATION)
	pass


func _on_Collision_body_entered(body):
	pass # Replace with function body.


func _on_Hurt_body_entered(body):
	if body.is_in_group("Enemies") and !body.stunned and !invincible:
		
		health -= 1
		if(health <= 0):
			global.Play(preload("res://SFX/kashadeath.wav"))
		else:
			global.Play(preload("res://SFX/kashahurt.wav"))
		controllock = true
		stunned = true
		#get reverse collision direction
		var hurtdirection = sign(global_position.x - body.global_position.x)
		print(hurtdirection)
		velocity.y = -150
		velocity.x = 100 * hurtdirection
		invincible = true
		$invinciblelabel.show()
		flashroot.travel("flash")
#		print("Ouch!")



func _on_AnimatedSprite_animation_finished():
	is_attacking = false

func Slide():
	pass

func Anims():
	
	if(is_on_floor()):
		if(direction == 0):
			root.travel("idle")
		else:
			root.travel("walk")
	else:
		root.travel("jump")
	
	if(is_attacking):
		root.travel("attack")


