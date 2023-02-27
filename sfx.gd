extends Node

onready var player1 = get_node("AudioStreamPlayer")
onready var player2 = $AudioStreamPlayer2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var last

func PlaySFX(filestring):
	match last:
		null:
			player1.set_stream(load(filestring))
			player1.play()
			last = player1
		player1:
			player2.set_stream(load(filestring))
			player2.play()
			last = player2
			pass
		player2:
			player1.set_stream(load(filestring))
			player1.play()
			last = player1
			pass
