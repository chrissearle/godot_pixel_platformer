tool
extends Path2D

enum ANIMATION_TYPE {
	LOOP,
	BOUNCE
}

export(ANIMATION_TYPE) var animation_type setget set_animation_type
export(int) var speed = 180 setget set_animation_speed

onready var animation_player = $AnimationPlayer

func _ready():
	play_updated_animation(animation_player) 

func play_updated_animation(player):
	match animation_type:
		ANIMATION_TYPE.LOOP:
			player.play("FollowPathLoop")
		ANIMATION_TYPE.BOUNCE:	
			player.play("FollowPathBounce")
	player.playback_speed = speed / curve.get_baked_length() 

func set_animation_type(value):
	animation_type = value
	var player = find_node("AnimationPlayer")
	if player:
		play_updated_animation(player) 

func set_animation_speed(value):
	speed = value
	var player = find_node("AnimationPlayer")
	if player:
		play_updated_animation(player) 
	
