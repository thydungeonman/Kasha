extends Node


enum SONGS {INVIN,SONG1,SONG2}
enum LEVELSONGS {SONG1 = 1, SONG2}

var musicvolume = 0.0
var sfxvolume = 0.0
onready var music = AudioStreamPlayer.new()
var songs = ["res://music/stage_theme_1_-_pestbustin.ogg", "res://music/stage_theme_2_-_broom_tail_boogie.ogg"]
var currentsong = null

func _ready():
	add_child(music)
	music.volume_db = -15


#return vector with vector.x multiplied by x
func VX(vector,x):
	vector.x *= x
	return vector

#return vector with vector.y multiplied by y
func VY(vector,y):
	vector.y *= y
	return vector

func PlaySong(song):
	if(song != currentsong):
		match song:
			SONGS.INVIN:
				music.set_stream(preload("res://music/invincibility.wav"))
				music.play()
				currentsong = song
			SONGS.SONG1:
				music.set_stream(preload("res://music/stage_theme_1_-_pestbustin.ogg"))
				music.play()
				currentsong = song
			SONGS.SONG2:
				music.set_stream(preload("res://music/stage_theme_2_-_broom_tail_boogie.ogg"))
				music.play()
				currentsong = song


func Play(sound,volume = sfxvolume):
	if sound == null:
		return
	var sfx = AudioStreamPlayer.new()
	get_tree().get_root().add_child(sfx)
	sfx.set_stream(sound)
	sfx.volume_db = volume
	sfx.connect("finished",sfx,"queue_free")
	sfx.play()
