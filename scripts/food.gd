extends Area2D

var thingsleft = 3
signal allout(spawn)
signal thingtaken
var spawn

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func Reset():
	show()
	get_node("Sprite").scale = Vector2(.2,.2)
	thingsleft = 3
	pass


func _on_food_body_entered(body):
	if(body.is_in_group("Enemies")):
		if(thingsleft > 0):
			if(!body.gotthing and !body.stunned):
				body.gotthing = true
				body.get_node("AnimatedSprite").modulate = Color(1,1,0)
				body.speed = 35
				scale = scale * .8
				
				thingsleft -= 1
				emit_signal("thingtaken")
				if(thingsleft == 0):
					emit_signal("allout",spawn)
					queue_free()

