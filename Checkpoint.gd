extends Area2D

onready var sprite: = $Sprite

var active = true

func _on_Checkpoint_body_entered(body):
	if not body is Player:
		return

	if not active:
		return
		
	active = false

	sprite.play("Checked")
	Events.emit_signal("hit_checkpoint", position)
