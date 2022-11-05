extends Node

const HURT = preload("res://Sounds/Hurt.wav")
const JUMP = preload("res://Sounds/Jump.wav")

onready var audio_players = $AudioPlayers

func play_sound(sound):
	for player in audio_players.get_children():
		if not player.playing:
			player.stream = sound
			player.play()
			break
