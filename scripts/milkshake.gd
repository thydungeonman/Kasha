extends KinematicBody2D

export var velocity  = Vector2(0,100)

func _ready():
	set_physics_process(true)



func _physics_process(delta):
	move_and_slide(velocity,Vector2.UP)
	pass

