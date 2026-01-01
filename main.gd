extends Node2D

@export var pipe_scene: PackedScene

const PIPE_SPACING := 600.0
const PIPE_COUNT := 5
const GAP_CENTER := 360.0
const GAP_VARIATION := 80.0

var score := 0
var game_over := false
var game_started := false
var pipes: Array = []


func _ready():
	# Signals
	$Bird.area_entered.connect(_on_bird_area_entered)
	$Bird.died.connect(_on_bird_died)

	# Buttons
	$UI/StartScreen/PlayButton.pressed.connect(_on_play_pressed)
	$UI/GameOverScreen/RetryButton.pressed.connect(_on_retry_pressed)

	# Initial UI state
	$UI/StartScreen.visible = true
	$UI/GameOverScreen.visible = false
	$UI/ScoreLabel.visible = false

	# Stop bird & music initially
	$Bird.active = false
	if $GameMusic:
		$GameMusic.stop()


# --------------------
# BUTTONS
# --------------------

func _on_play_pressed():
	game_started = true
	game_over = false
	score = 0

	# UI
	$UI/StartScreen.visible = false
	$UI/GameOverScreen.visible = false
	$UI/ScoreLabel.visible = true
	$UI/ScoreLabel.text = "0"

	# Reset bird
	$Bird.position = Vector2(200, GAP_CENTER)
	$Bird.velocity = 0
	$Bird.active = true

	# Pipes
	_clear_pipes()
	_spawn_initial_pipes()

	# Music
	if $GameOverMusic:
		$GameOverMusic.stop()
	if $GameMusic:
		$GameMusic.play()

	get_tree().paused = false


func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()



# --------------------
# PIPES
# --------------------

func _spawn_initial_pipes():
	var start_x = 1280 + 200

	for i in range(PIPE_COUNT):
		var pipe = pipe_scene.instantiate()
		pipe.position.x = start_x + i * PIPE_SPACING
		pipe.position.y = _random_gap_y()
		add_child(pipe)
		pipes.append(pipe)


func _process(_delta):
	if not game_started or game_over:
		return

	for pipe in pipes:
		if pipe.position.x < -200:
			_recycle_pipe(pipe)


func _recycle_pipe(pipe):
	var farthest_x := 0.0
	for p in pipes:
		farthest_x = max(farthest_x, p.position.x)

	pipe.position.x = farthest_x + PIPE_SPACING
	pipe.position.y = _random_gap_y()
	pipe.scored = false


func _random_gap_y() -> float:
	return randf_range(
		GAP_CENTER - GAP_VARIATION,
		GAP_CENTER + GAP_VARIATION
	)


func _clear_pipes():
	for p in pipes:
		p.queue_free()
	pipes.clear()


# --------------------
# COLLISIONS
# --------------------

func _on_bird_area_entered(area: Area2D):
	if game_over:
		return

	var pipe = area.get_parent()

	if area.is_in_group("pipe"):
		_end_game()

	elif area.is_in_group("score") and not pipe.scored:
		pipe.scored = true
		score += 1
		$UI/ScoreLabel.text = str(score)
		if $PointSound:
			$PointSound.play()


func _on_bird_died():
	if game_over:
		return
	_end_game()


# --------------------
# GAME OVER
# --------------------

func _end_game():
	game_over = true
	$Bird.active = false

	$UI/GameOverScreen.visible = true
	$UI/StartScreen.visible = false
	$UI/ScoreLabel.visible = false

	if $GameMusic:
		$GameMusic.stop()
	if $GameOverMusic:
		$GameOverMusic.play()

	get_tree().paused = true


func _on_retry_button_pressed() -> void:
	pass # Replace with function body.
