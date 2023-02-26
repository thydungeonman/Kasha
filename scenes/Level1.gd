extends Node2D

onready var UI = get_node("Player/Camera2D/UI")

var lastkill = 0.0 #time since last kill
var multiplier = 1.0
var numrats = 60
var score = 0


func _ready():
	randomize()
	var b = randi() % global.LEVELSONGS.size()
	var a = global.LEVELSONGS.values()[b]
	global.PlaySong(a)
	set_process(true)

func _process(delta):
	
	lastkill += delta
	if(lastkill > 1.0):
		multiplier = 1.0

func _on_Timer_timeout():
	if(numrats > 0):
		var rat = load("res://scenes/EnemyRat.tscn").instance()
		add_child(rat)
		rat.translate(Vector2(330 + randi() % 100,20))
		if(randi() % 2 == 1):
			rat.Flip()
		rat.connect("died",self,"AnotherOneGone")
		numrats -= 1

func AnotherOneGone():
	UI.get_node("time").text = str(numrats)
	if(lastkill < 2.0):
		multiplier += .5
	lastkill = 0.0
	score += 100 * multiplier
	print(score)
	print(multiplier)
	UI.get_node("score").text = str(score)
	pass


func _on_roundtime_timeout():
	score = 0
	UI.get_node("score").text = str(score)
	pass # Replace with function body.


func _on_milkshaketimer_timeout():
	var shake = preload("res://scenes/milkshake.tscn").instance()
	randomize()
	var pos = Vector2(randi() % 450,randi() % 150)
	shake.position = pos
	add_child(shake)
	pass # Replace with function body.
