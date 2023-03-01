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


var is_attacking = false
var rapid_attacking = false
var pressing_attack = false

var knockback_dir = Vector2()
var knockback_wait = 30

var controllock = false
var direction = 0  #1 for right -1 for left 0 for not moving
var facing = 1 #1 for right -1 for left   no such thing as facing 0

export var health = 4
var stunned = false
export var invincibletime = .5
var invincibletimer = 0.0 #might just use a regular timer though
var invincible = false

var powerinvincible = false
export var powerinvincibletime = 12
var dontstop = false


#might do a different thing where it just checks when the timer is up if you pressed attack
# before the timer is up to see of it should attack again



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
				
	
	Attacks(delta)
	
	Anims()
	

var attacking = false
var pressedattack = false
var rapidattacking = false
var attack = null
var movelock = false

#complete rework of attacking
func Attacks(delta):
	if(Input.is_action_just_pressed("ui_action")):
		if(attacking):
			pressedattack = true
			movelock = true
		else:
			SpawnAttack()
			var t = Timer.new()
			t.wait_time = .4
			t.connect("timeout",self,"StopAttacking",[t],CONNECT_ONESHOT)
			add_child(t)
			t.start()
			attacking = true
			
			

func SpawnAttack():
	attack = preload("res://scenes/Attack.tscn").instance()
	controllock = true
	add_child(attack)
	attack.translate(Vector2(15 * facing,0))
	attack.direction = facing


func StopAttacking(tim):
	#if we havent pressed the attack button since attack started then stop attacking and rapid attacking
	#else we will start to rapid attack
	tim.queue_free()
	if(pressedattack):
		SpawnAttack()
		var t = Timer.new()
		t.wait_time = .25
		t.connect("timeout",self,"StopAttacking",[t],CONNECT_ONESHOT)
		add_child(t)
		t.start()
		rapidattacking = true
		pressedattack = false
		pass
	else:
		attacking = false
		movelock = false
		pass
	pass
	
func StopRapidAttacking():
	if(!dontstop):
		is_attacking = false
		rapid_attacking = false

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
#			global.Play(preload("res://SFX/kashajump.wav"))
			global.sfx.PlaySFX("res://SFX/kashajump.wav")
			velocity.y = JUMP_STRENGTH
		
	else: 
#		if !is_attacking:
#			animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_accept") and velocity.y < -150:
			velocity.y = -150
			
	
	velocity = move_and_slide(velocity * 60 * delta * (1/Engine.time_scale), Vector2.UP)


func apply_gravity():
	velocity.y += GRAVITY

func apply_friction():
	if(!stunned):
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	else:
		velocity.x = move_toward(velocity.x,0,2.5)
	pass

func apply_acceleration(movedirection):
	if(movelock):
		movedirection = 0
	velocity.x = move_toward(velocity.x, MAX_SPEED * movedirection, ACCELERATION)
	pass


func _on_Collision_body_entered(body):
	pass # Replace with function body.


func _on_Hurt_body_entered(body):
	if body.is_in_group("Enemies") and !body.stunned and !invincible and !powerinvincible:
		health -= 1
		if(health <= 0):
#			global.Play(preload("res://SFX/kashadeath.wav"))
			global.sfx.PlaySFX("res://SFX/kashadeath.wav")
		else:
			global.sfx.PlaySFX("res://SFX/kashahurt.wav")
#			global.Play(preload("res://SFX/kashahurt.wav"))
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
	elif(body.is_in_group("Enemies") and !body.stunned and powerinvincible):
		body.Damage(direction)
	elif(body.is_in_group("powerup")):
		PowerUpInvincible()
		body.queue_free()





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
	
	if(attacking):
		root.travel("attack")
		if(rapidattacking):
			root.travel("attack rapid")


var playbackpos = 0.0
var oldsong = null
var ti
func PowerUpInvincible():
	if(ti != null):
		ti.queue_free()
		ti = null
	powerinvincible = true
	flashroot.travel("flash")
	ti = Timer.new()
	add_child(ti)
	ti.wait_time = powerinvincibletime
	ti.connect("timeout",self,"PowerUpInvincibleDone",[],CONNECT_ONESHOT)
	ti.start()
	if(global.currentsong != global.SONGS.INVIN):
		oldsong = global.currentsong
	playbackpos = global.music.get_playback_position()
	global.PlaySong(global.SONGS.INVIN)
	

func PowerUpInvincibleDone():
	ti.queue_free()
	ti = null
	powerinvincible = false
	flashroot.travel("RESET")
	global.PlaySong(oldsong)
	global.music.seek(playbackpos)
	print(str(playbackpos))

	
