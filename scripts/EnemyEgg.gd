extends "res://scripts/EnemyBase.gd"

export var timetohatch = 3.0
export var pushspeed = 30
export var slowdown = 10
export var rollgranularity = 10

var flipped = false
var fellfromheight = false
var hatching = false #goes to true when hatching animation starts

# 0 1 2 3 4 f3 f2 f1 ->
onready var anim = get_node("AnimationPlayer")

var rollbuffer = 0

var enemies = []
var lastoverlapenemies = []


func _ready():
	set_collision_layer_bit(2,true)
	health = 3
#	$eggtimer.wait_time = timetohatch
	$eggtimer.start()
	
	

func _physics_process(delta):
	if(velocity == Vector2()):
		$ratbox.monitoring = false
		set_collision_layer_bit(9,true)
	else:
		$ratbox.monitoring = true
		set_collision_layer_bit(9,false)
	
	if($ratbox.monitoring):
		enemies = $ratbox.get_overlapping_bodies()
		for body in enemies:
			if(body.is_in_group("Players")):
				continue
			if(body.is_in_group("Egg")):
				continue
			if(!lastoverlapenemies.has(body)):
				if(!body.stunned):
					var a  = body.name
					print(str(a))
					print(a)
					body.Damage(direction)
					
		lastoverlapenemies = enemies
	
	
	
#	print(delta)
	velocity.y += GRAVITY
#	print(velocity.y)
	if(velocity.y > 200):
		fellfromheight = true
	if(is_on_floor()):
		velocity.y = 0
		if(fellfromheight):
			fellfromheight = false
			print(anim.connect("animation_finished",self,"Die",[],CONNECT_ONESHOT))
			$AnimationPlayer.play("break")
			$eggtimer.stop()
			$rolltimer.stop()
			set_physics_process(false)
			return
			
	var v = TrueVelocity()
	move_and_slide(v * delta * 60 * (1/Engine.time_scale),Vector2.UP)
	
	rollbuffer += velocity.x / 2 * direction
	
	if(rollbuffer < 0):
		if(!flipped):
			rollbuffer = 44
			$Sprite.frame -= 1
			if($Sprite.frame == 0):
#				$Sprite.frame = 1
				flipped = true
				$Sprite.flip_h = !$Sprite.flip_h
			
		else:
			rollbuffer = 44
			$Sprite.frame += 1
			if($Sprite.frame == 4):
#				$Sprite.frame = 3
				flipped = false
				$Sprite.flip_h = !$Sprite.flip_h
			
		
	elif(rollbuffer > 45):
		rollbuffer = 0
		if(!flipped):
			$Sprite.frame += 1
			if($Sprite.frame == 5):
				flipped = true
				$Sprite.flip_h = !$Sprite.flip_h
				$Sprite.frame = 3
		else:
			$Sprite.frame -= 1
			if($Sprite.frame == 0):
				flipped = false
				$Sprite.flip_h = !$Sprite.flip_h
				$Sprite.frame = 0
			
		
#	print($Sprite.frame)
	velocity.x = velocity.x - (velocity.x /20)
	if(velocity.x < .05):
		velocity.x = 0
		
	pass

func Damage(dir,newvelocity = null):
	health -= 1
	if(health == 0):
		$AnimationPlayer.play("break")
		return true
	return false

func Push(dir):
	print(dir)
	direction = dir
	velocity.x = pushspeed
	print(direction)
	$rolltimer.start()
#	$AnimationPlayer.advance(.1 * direction)


func _on_rolltimer_timeout():
	#reorient self
	#probably just use a tween and go toward frame 4
#	print("ROLL")
#	print(velocity.x)
	if(velocity.x == 0):
		var t = get_tree().create_tween().tween_property($Sprite,"frame",0,.3)
		$rolltimer.stop()
	else:
		$rolltimer.start()
	
	


func Die():
	print("WHAT")
	emit_signal("died")
	queue_free()
	pass

func Break():
	set_physics_process(false)
	$ratbox.monitoring = false
	BecomeEthereal()
	$AudioStreamPlayer2.play()

#put down a bird where the egg was,  probably have its flight level be just above where the egg was
func SpawnBird():
	BecomeEthereal()
	$ratbox.monitoring = false
	set_physics_process(false)
	var bird = load("res://scenes/EnemyCuckoo2.tscn").instance()
	get_parent().add_child(bird)
	var p = global_position
	
	bird.global_position = p
	
	if(randi() % 2 == 1):
		bird.Flip()
	bird._on_flighttimer_timeout()
	bird.flighttimer.stop()
	bird.flighttimer.start()
	bird.connect("died",self,"AnotherOneGone")


func BecomeEthereal():
	set_collision_layer_bit(2,false)
	set_collision_layer_bit(4,false)
	pass


func _on_eggtimer_timeout():
	$AnimationPlayer.play("hatch")
	pass # Replace with function body.
