extends Node

var musicvolume = 0.0
var sfxvolume = 0.0

var songs = ["res://music/stagetheme1.wav", "res://music/stagetheme2.wav"]


func _ready():
	pass # Replace with function body.

#return vector with vector.x multiplied by x
func VX(vector,x):
	vector.x *= x
	return vector

#return vector with vector.y multiplied by y
func VY(vector,y):
	vector.y *= y
	return vector


func Play(sound,volume = sfxvolume):
	if sound == null:
		return
	var sfx = AudioStreamPlayer.new()
	get_tree().get_root().add_child(sfx)
	sfx.set_stream(sound)
	sfx.volume_db = volume
	sfx.connect("finished",sfx,"queue_free")
	sfx.play()
