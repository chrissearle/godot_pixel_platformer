extends KinematicBody2D

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

export(int) var SPEED = 25

onready var animated_sprite = $AnimatedSprite
onready var ledge_check_right = $LedgeCheckRight
onready var ledge_check_left = $LedgeCheckLeft

func _ready():
	animated_sprite.playing = true
	set_sprite_direction()

func _physics_process(delta):
	var found_wall = is_on_wall()
	
	var found_ledge = not ledge_check_right.is_colliding() or not ledge_check_left.is_colliding()
	
	if found_wall or found_ledge:
		direction *= -1
		set_sprite_direction()
	
	
	velocity = direction * SPEED	
	move_and_slide(velocity, Vector2.UP)

func set_sprite_direction():
	animated_sprite.flip_h = (direction == Vector2.RIGHT)
