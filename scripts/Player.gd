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

var dashspeeds = [70,100,120,160]  #0-3


export var FULLDASHSPEED = 130
var is_attacking = false
var rapid_attacking = false
var pressing_attack = false
var holdingattack = false

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


var dashlevel = 0 #0 = not dashing then 1,2,3
export var dashtime = 0.6
var dashtimer = 0.0
var smallholdtime = .2
var smallholdtimer = 0.0 #just so we KNOW the player is holding
#might do a different thing where it just checks when the timer is up if you pressed attack
# before the timer is up to see of it should attack again



func _ready():
	
#	Engine.time_scale = 2
	
	root.start("idle")
	flashroot.start("RESET")
	


func GoThroughFloor():
	print("done")
	set_collision_mask_bit(0,true)

var t
func _process(delta):
	
	LabelCheck()
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
var pressedattack = false #ONLY FOR KNOWING IF ATTACK IS PRESSED DURING ATTACK ANIMATION
var rapidattacking = false
var attack = null
var movelock = false
var lastframe = false
var dashattack = null # ref to the actual attack scene
#complete rework of attacking
func Attacks(delta):
	
	if(Input.is_action_pressed("ui_action")): # holding the button
		if(smallholdtimer > smallholdtime): 
			holdingattack = true
			if(dashlevel > 0):
				dashtimer += delta
				if(dashtimer > dashtime):
					dashlevel += 1
					dashtimer = 0.0
					if(dashlevel > 3):
						dashlevel = 3
		smallholdtimer += delta
	if(Input.is_action_just_released("ui_action")):
		if(smallholdtimer > smallholdtime):
			attacking = false
		if(dashlevel > 0):
			if(dashattack != null):
				dashattack.queue_free()
				dashattack = null
			attacking = false
		holdingattack = false
		dashlevel = 0
		dashtimer = 0.0
		smallholdtimer = 0.0
	
	
	
	
	if(Input.is_action_just_pressed("ui_action")):
		holdingattack = true
		if(attacking and !airattacking):
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
	
	
	
var airattacking = false  #only for knowing if we started attacking when we were the air

func SpawnAttack():
	if(is_on_floor()):
		attack = preload("res://scenes/Attack.tscn").instance()
		if(direction == 0):
			controllock = true
		add_child(attack)
		attack.translate(Vector2(15 * facing,0))
		attack.direction = facing
	else:
		attack = preload("res://scenes/Attack spin.tscn").instance()
#		controllock = true
		add_child(attack)
		attack.translate(Vector2(0,0))
		attack.direction = facing
		airattacking = true


func StopAttacking(tim):
	#if we havent pressed the attack button since attack started then stop attacking and rapid attacking
	#else we will start to rapid attack
	tim.queue_free()
	if(holdingattack):
		#start dash attack if direction != 0
		if(direction != 0):
			dashlevel = 1
			dashattack = load("res://scenes/Dash Attack.tscn").instance()
			add_child(dashattack)
			dashattack.position.x = (15 * facing)
			dashattack.direction = facing
			return
		pass
	
	if(pressedattack and !airattacking):
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
		rapidattacking = false
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

var pressedjump = false
func _physics_process(delta):
	apply_gravity()
	HorizontalForces()
	if(stunned and velocity.x == 0):
		stunned = false
		controllock = false
		if(invincible):
			t = get_tree().create_timer(invincibletime)
			t.connect("timeout",self,"StopInvincible",[],CONNECT_ONESHOT)
	
	EggCheck()
	
	if direction == 0:
		apply_friction();
	else:
		apply_acceleration(direction);
		if direction > 0:
			$Sprite.flip_h = false
		elif direction < 0:
			$Sprite.flip_h = true
		
	if is_on_floor():
		pressedjump = false
		if(airattacking):
			attacking = false
			airattacking = false
		if Input.is_action_just_pressed("ui_accept") and not controllock and !Input.is_action_pressed("ui_down"):
			global.sfx.PlaySFX("res://SFX/kashajump.wav")
			velocity.y = JUMP_STRENGTH
			pressedjump = true
		
	else: 
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
	velocity.x = move_toward(velocity.x, dashspeeds[dashlevel] * movedirection, ACCELERATION)
	pass


func _on_Hurt_body_entered(body):
	if body.is_in_group("Enemies") and !body.is_in_group("Egg") and !body.stunned and !invincible and !powerinvincible:
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
		attacking = false
#		print("Ouch!")
	elif(body.is_in_group("Enemies") and !body.stunned and powerinvincible):
		body.Damage(direction)
	elif(body.is_in_group("powerup")):
		PowerUpInvincible()
		body.queue_free()


func Slide():
	pass

func Anims():
	
	
	if(attacking):
		if(is_on_floor()):
			if(dashlevel != 0):
				match dashlevel:
					1:
						root.travel("dash")
					2:
						root.travel("dash 2")
					3:
						root.travel("dash 3")
			else:
				if(velocity.x != 0):
					root.travel("dash start")
					print("dash start")
				else:
					root.travel("attack")
					print("attack")
				if(rapidattacking):
					root.travel("attack rapid")
		else:
			if(dashlevel > 1):
				if(pressedjump):
					root.travel("air spin super")
			else:
				root.travel("air spin")
	else:
		if(is_on_floor()):
			if(direction == 0):
				root.travel("idle")
				print("idle")
			else:
				root.travel("walk")
				print("walk")
		else:
			if(dashlevel < 1):
				root.travel("jump")


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



func EggCheck():
	for s in range(get_slide_count()):
		var slide = get_slide_collision(s)
		if(slide.collider != null):
#			print(slide.collider.name)
			if(slide.collider.is_in_group("Egg")):
				if(is_on_wall()):
					slide.collider.Push(direction)



var Hforces = [] #vector3s
#force, reduction per frame, direction
func HorizontalForces():
	for v in Hforces:
		velocity.x += v.x * v.z
	var bads = []
	for v in range(Hforces.size()-1,-1,-1):
		Hforces[v].x -= Hforces[v].y
		if(Hforces[v].x < 0):
			bads.push_back(v)
	for b in bads:
		Hforces.remove(b)
		pass
	
	pass


func LabelCheck():
	$attackinglabel.visible = attacking
	$airattackinglabel.visible = airattacking
	$rapidattackinglabel.visible = rapidattacking
	$controllocklabel.visible = controllock
	$holdingattacklabel.visible = holdingattack
	$pressedattacklabel.visible = pressedattack
	if(dashlevel > 0):
		$dashlabel.visible = true
		$dashlabel.text = "dash level: " + str(dashlevel)
	else:
		$dashlabel.visible = false
