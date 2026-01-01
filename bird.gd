extends Area2D

signal died

@export var fall_gravity := 1200.0
@export var jump_force := -420.0

var velocity := 0.0

func _physics_process(delta):
	velocity += fall_gravity * delta

	if Input.is_action_just_pressed("flap"):
		velocity = jump_force

	position.y += velocity * delta


func _on_area_entered(area: Area2D):
	if area.is_in_group("ground"):
		emit_signal("died")
