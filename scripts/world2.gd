extends Node2D

onready var music = get_node("AudioStreamPlayer")

onready var spawns = [$spawn1, $spawn2, $spawn3]
onready var holes = [$hole, $hole2]
onready var foodspawns = [$foodspawn, $foodspawn2, $foodspawn3, $foodspawn4, $foodspawn5, $foodspawn6, $foodspawn7]
onready var UI = get_node("Player/Camera2D/UI")

var speedup = false
var score = 0
var done = false

func _ready():
	randomize()
	music.stream = load(global.songs[randi() % global.songs.size() ])
	music.play()
	set_process(true)
	for h in holes:
		h.connect("ratescape",self,"QuickSpawn")
	
	for i in range(3):
		var f = preload("res://scenes/food.tscn").instance()
		var spot = randi() % foodspawns.size()
		f.translate(foodspawns[spot].global_position)
		f.spawn = foodspawns[spot]
		foodspawns.remove(spot)
		f.connect("allout",self,"NewFood")
		f.connect("thingtaken",self,"Count")
		add_child(f)
		

func Count():
	score += 1
	UI.get_node("score").text = str(score)

func NewFood(spawn):
	if !done:
		foodspawns.push_back(spawn)
		var f = preload("res://scenes/food.tscn").instance()
		var spot = randi() % foodspawns.size()
		f.translate(foodspawns[spot].global_position)
		f.spawn = foodspawns[spot]
		foodspawns.remove(spot)
		f.connect("allout",self,"NewFood")
		call_deferred("add_child",f)
	pass

func _process(delta):
	UI.get_node("time").text = str($roundtime.time_left)
	if($roundtime.time_left < 15.0):
		if(!speedup):
			speedup = true
			$Timer.wait_time = 1.0
	pass

func _on_Timer_timeout():
	if(!done):
		var rat = load("res://scenes/EnemyRat.tscn").instance()
		add_child(rat)
		var r = randi() % spawns.size()
		rat.translate(spawns[r].global_position)
		if(randi() % 2 == 1):
			rat.Flip()
	


func QuickSpawn():
	if(!done):
		var rat = load("res://scenes/EnemyRat.tscn").instance()
		
		var r = randi() % spawns.size()
		rat.translate(spawns[r].global_position)
		call_deferred("add_child",rat)


func _on_roundtime_timeout():
	done = true
	$roundtime.stop()
	pass # Replace with function body.
