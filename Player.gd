extends KinematicBody2D

export(int) var MAX_SPEED = 75 * 60

export(int) var ACCELERATION = 10 * 60
export(int) var FRICTION = 10 * 60
export(int) var GRAVITY = 5 * 60
export(int) var MAX_GRAVITY = 300 * 60

export(int) var JUMP_FORCE = 160 * 60
export(int) var JUMP_RELEASE_FORCE = 40 * 60
export(int) var FAST_FALL_GRAVITY = 2 * 60

var velocity = Vector2.ZERO

onready var animated_sprite = $AnimatedSprite

func _ready():
	randomize()
	if bool(randi() % 2):
		animated_sprite.frames = load("res://PlayerGreenSkin.tres")
	else:
		animated_sprite.frames = load("res://PlayerBlueSkin.tres")
		
	animated_sprite.playing = true

func _physics_process(delta):
	velocity.y = apply_gravity(velocity, delta)

	var movement = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	var animation = get_animation(movement)

	velocity.x = apply_movement(movement, delta)

	velocity.y = apply_jump(velocity, delta)

	set_sprite_direction(movement)

	animated_sprite.animation = animation

	var was_jumping = !is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)

	var is_jumping = !is_on_floor()

	# Handle changing frame when changing animation from jump to run
	if (was_jumping and not is_jumping):
		animated_sprite.animation = "Run"
		animated_sprite.frame = 1

func apply_jump(v, delta):
	var amount = v.y

	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			amount = -JUMP_FORCE * delta
	else:
		# Close to apex
		if Input.is_action_just_released("ui_up") and velocity.y < -(JUMP_RELEASE_FORCE * delta):
			amount = -JUMP_RELEASE_FORCE * delta

		# Falling - increase gravity a little
		if velocity.y > 0:
			amount += FAST_FALL_GRAVITY * delta

	return amount
	
func get_animation(movement):
	var animation = "Idle"
	
	if not close_to_equal(0, movement):
		animation = "Run"
	
	if not is_on_floor():
		animation = "Jump"
	
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
	return min(v.y + GRAVITY * delta, MAX_GRAVITY * delta)
	

func apply_friction(v, delta):
	return move_toward(v.x, 0, FRICTION * delta)

func apply_acceleration(v, amount, delta):
	return move_toward(v.x, MAX_SPEED * amount * delta, ACCELERATION * delta)

const FLOAT_EPSILON = 0.00001

static func close_to_zero(value):
	return close_to_equal(0, value)

static func close_to_equal(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon
