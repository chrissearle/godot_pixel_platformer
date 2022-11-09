extends Node2D

const player_scene = preload("res://Player/Player.tscn")

var player_spawn_location = Vector2.ZERO

onready var camera: = $Camera2D
onready var player: = $Player
onready var timer: = $Timer

func _ready():
	VisualServer.set_default_clear_color(Color.lightblue)
	
	player.connect_camera(camera)
	player_spawn_location = player.global_position

	Events.connect("player_died", self, "_on_player_died")
	Events.connect("hit_checkpoint", self, "_on_hit_checkpoint")

func _on_hit_checkpoint(pos):
	player_spawn_location = pos

func _on_player_died():
	timer.start(1)
	yield(timer, "timeout")
	
	var player = player_scene.instance()
	player.position = player_spawn_location
	add_child(player)
	player.connect_camera(camera)
