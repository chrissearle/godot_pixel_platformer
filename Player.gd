extends KinematicBody2D

export(int) var MAX_SPEED = 75 * 60

export(int) var  ACCELERATION = 10 * 60
export(int) var  FRICTION = 10 * 60
export(int) var  GRAVITY = 5 * 60

export(int) var  JUMP_FORCE = 160 * 60
export(int) var  JUMP_RELEASE_FORCE = 40 * 60
export(int) var  FAST_FALL_GRAVITY = 2 * 60

var velocity = Vector2.ZERO

func _physics_process(delta):
	velocity.y = apply_gravity(velocity, delta)

	var movement = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	velocity.x = apply_movement(movement, delta)

	velocity.y = apply_jump(velocity, delta)

	velocity = move_and_slide(velocity, Vector2.UP)

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

func apply_movement(movement, delta):
	var amount = 0
	
	if close_to_equal(0, movement):
		amount = apply_friction(velocity, delta)
	else:
		amount = apply_acceleration(velocity, movement, delta)

	return amount

func apply_gravity(v, delta):
	return v.y + GRAVITY * delta

func apply_friction(v, delta):
	return move_toward(v.x, 0, FRICTION * delta)

func apply_acceleration(v, amount, delta):
	return move_toward(v.x, MAX_SPEED * amount * delta, ACCELERATION * delta)

const FLOAT_EPSILON = 0.00001

static func close_to_equal(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon
