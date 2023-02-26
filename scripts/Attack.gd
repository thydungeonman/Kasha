extends Area2D
signal knockback

#the hit box for our attack. We spawn it when we hit our attack button. 
#It lasts for however long we want and then frees (deletes) itself

#one thing about using areas like this though is that they will NOT collide with anything on the first frame that they are moved or spawned 
#this includes right when the game starts or the scene starts
#so they need at least one frame to update

var lifetime = .2 #the time until deleted in seconds
var timer = 0.0 # the variable that will count the time for us

var direction = 1
#alternatively we could attach a timer node to this scene instead


func _ready():
	set_process(true)
	set_physics_process(true)



func _process(delta):
	
	timer += delta
	if(timer > lifetime):
		if(!get_parent().rapid_attacking):
			get_parent().controllock = false
		get_parent().attack = null
		queue_free() 

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Enemies"):
			body.Damage(direction)
			emit_signal("knockback") 
			set_physics_process(false) 
			if(!get_parent().rapid_attacking):
				get_parent().controllock = false
			get_parent().attack = null
			queue_free()
	#if we are overlapping with an enemy then damage it and then free ourselves right after
	#use get_overlapping_bodies() and run through each one in a for loop
	#if body is in group "rat" or maybe body is in group "enemy"
	#body.Bonk()
	#queue_free()  so the hit box doesn't stick around any longer  sometimes queue_free() can take a frame or two to finally delete the scene though
	#set_physics_process(false)   so we dont keep detecting enemies and hitting them
	
	#instead of the above two lines we could just call free() which deletes the scene immediately
	#but people say that queue_free() is generally safer in terms of memory or whatever
	#ive never had any problems with just using free() when ive had to
	pass
