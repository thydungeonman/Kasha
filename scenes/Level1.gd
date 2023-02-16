extends Node2D

onready var music = get_node("AudioStreamPlayer")

func _ready():
	randomize()
	music.stream = load(global.songs[randi() % global.songs.size() ])
	music.play()
	set_process(true)
	pass # Replace with function body.

func _process(delta):
	$musiclabel.text = str(music.get_playback_position())

func _on_Timer_timeout():
	
	var rat = load("res://scenes/EnemyRat.tscn").instance()
	add_child(rat)
	rat.translate(Vector2(330,20))
	if(randi() % 2 == 1):
		rat.Flip()
	
