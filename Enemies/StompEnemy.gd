extends Node2D

enum {
	HOVER,
	FALL,
	LAND,
	RISE
}

var state = HOVER

onready var start_position = global_position

onready var timer: = $Timer
onready var ray_cast: = $RayCast2D
onready var animated_sprite: = $AnimatedSprite
onready var particles: = $Particles2D

var fall_speed = 200
var rise_speed = 20

func _ready():
	particles.one_shot = true
	particles.emitting = false

func _physics_process(delta):
	match state:
		HOVER:
			hover_state()
		
		FALL:
			fall_state(delta)
		
		LAND:
			land_state()
		
		RISE:
			rise_state(delta)
			
func hover_state():
	if timer.time_left == 0:
		state = FALL

func fall_state(delta):
	animated_sprite.play("Falling")
	position.y += fall_speed * delta

	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		position.y = collision_point.y
		state = LAND
		particles.emitting = true
		timer.start(1.0)

func land_state():
	if timer.time_left == 0:
		state = RISE

func rise_state(delta):
	animated_sprite.play("Rising")
	position.y = move_toward(position.y, start_position.y, rise_speed  * delta)
	if position.y == start_position.y:
		timer.start(2.0)
		state = HOVER
