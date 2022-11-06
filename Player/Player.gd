extends KinematicBody2D

class_name Player

export(Resource) var move_data

var velocity = Vector2.ZERO

onready var animated_sprite: = $AnimatedSprite
onready var ladder_check: = $LadderCheck
onready var jump_buffer_timer: = $JumpBufferTimer
onready var coyote_jump_timer: = $CoyoteJumpTimer
onready var remote_transform_2d: = $RemoteTransform2D

onready var double_jump = move_data.DOUBLE_JUMPS

enum {
	MOVE,
	CLIMB
}

var state = MOVE

var buffered_jump = false
var coyote_jump = false

func _ready():
	randomize()
	if bool(randi() % 2):
		animated_sprite.frames = load("res://Player/PlayerGreenSkin.tres")
	else:
		animated_sprite.frames = load("res://Player/PlayerBlueSkin.tres")
		
	animated_sprite.playing = true

func _physics_process(delta):
	if is_on_ladder():
		pass

	var input = Vector2.ZERO

	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")

	match state:
		MOVE:
			move_state(input, delta)
		CLIMB:
			climb_state(input, delta)


func move_state(input, delta):
	if is_on_ladder() and Input.is_action_just_pressed("ui_up"):
		state = CLIMB

	velocity.y = apply_gravity(velocity, delta)

	var animation = get_animation(input)

	velocity.x = apply_movement(input.x, delta)

	velocity.y = apply_jump(velocity, delta)

	set_sprite_direction(input.x)

	animated_sprite.animation = animation

	var was_jumping = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)

	var is_jumping = not is_on_floor()
	# Handle changing frame when changing animation from jump to run
	if (was_jumping and not is_jumping):
		animated_sprite.animation = "Run"
		animated_sprite.frame = 1

	var just_left_ground = not is_on_floor() and was_on_floor
	
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyote_jump_timer.start()
	
func climb_state(input, delta):
	if not is_on_ladder():
		state = MOVE

	velocity = input * move_data.CLIMB_RATE * delta

	velocity = move_and_slide(velocity, Vector2.UP)
	
	animated_sprite.animation = get_animation(input)

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	Events.emit_signal("player_died")
	queue_free()

func is_on_ladder():
	if not ladder_check.is_colliding():
		return false
	
	var collider = ladder_check.get_collider()
	
	if not collider is Ladder:
		return false
	
	return true

func apply_jump(v, delta):
	var amount = v.y
	
	if is_on_floor():
		reset_double_jump()

	if can_jump():
		if wants_to_jump():
			amount = perform_jump(delta)
	else:
		if close_to_apex(delta):
			amount = jump_release(delta)
			
		if can_double_jump():
			amount = perform_jump(delta)
			double_jump -= 1

		if wants_to_buffer_jump():
			perform_buffer_jump()
		
		# Falling - increase gravity a little
		if velocity.y > 0:
			amount += move_data.FAST_FALL_GRAVITY * delta

	return amount
	
func get_animation(input):
	var animation = "Idle"
	
	match state:
		MOVE:	
			if not close_to_equal(0, input.x):
				animation = "Run"
			
			if not is_on_floor():
				animation = "Jump"
		CLIMB:
			if not close_to_equal(0, input.y):
				animation = "Run"
	
	return animation

func apply_movement(movement, delta):
	var amount = 0
	
	if close_to_zero(movement):
		amount = apply_friction(velocity, delta)
	else:
		amount = apply_acceleration(velocity, movement, delta)

	return amount

func set_sprite_direction(movement):
	if not close_to_zero(movement):
		$AnimatedSprite.flip_h = movement > 0

func apply_gravity(v, delta):
	return min(v.y + move_data.GRAVITY * delta, move_data.MAX_GRAVITY * delta)
	

func apply_friction(v, delta):
	return move_toward(v.x, 0, move_data.FRICTION * delta)

func apply_acceleration(v, amount, delta):
	return move_toward(v.x, move_data.MAX_SPEED * amount * delta, move_data.ACCELERATION * delta)

const FLOAT_EPSILON = 0.00001

static func close_to_zero(value):
	return close_to_equal(0, value)

static func close_to_equal(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon


func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false

func reset_double_jump():
	double_jump = move_data.DOUBLE_JUMPS

func wants_to_jump():
	return Input.is_action_just_pressed("ui_up") or buffered_jump
	
func perform_jump(delta):
	buffered_jump = false
	SoundPlayer.play_sound(SoundPlayer.JUMP)
	return -move_data.JUMP_FORCE * delta

func perform_buffer_jump():
	buffered_jump = true
	jump_buffer_timer.start()

func can_jump():
	return is_on_floor() or coyote_jump

func close_to_apex(delta):
	return Input.is_action_just_released("ui_up") and velocity.y < -(move_data.JUMP_RELEASE_FORCE * delta)

func jump_release(delta):
	return -move_data.JUMP_RELEASE_FORCE * delta

func can_double_jump():
	return Input.is_action_just_pressed("ui_up") and double_jump > 0

func wants_to_buffer_jump():
	return Input.is_action_just_pressed("ui_up")

func connect_camera(camera):
	var camera_path = camera.get_path()
	remote_transform_2d.remote_path = camera_path
