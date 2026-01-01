extends Sprite2D

func _process(_delta):
	var screen = get_viewport_rect().size
	scale = Vector2(
		screen.x / texture.get_width(),
		screen.y / texture.get_height()
	)
	position = screen / 2
