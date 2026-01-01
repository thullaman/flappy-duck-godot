extends Node2D

@export var speed := 240.0
@export var gap := 0   # FIXED reasonable gap

var scored := false

func _ready():
	var top_sprite = $TopPipe/Sprite2D
	var bottom_sprite = $BottomPipe/Sprite2D

	# flip ONLY the top sprite
	top_sprite.flip_v = true
	bottom_sprite.flip_v = false

	var top_h = top_sprite.texture.get_height()
	var bottom_h = bottom_sprite.texture.get_height()

	$TopPipe.position.y = -gap / 2 - top_h / 2
	$BottomPipe.position.y = gap / 2 + bottom_h / 2

	$ScoreZone.position = Vector2.ZERO


func _process(delta):
	position.x -= speed * delta
