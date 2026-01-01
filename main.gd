extends Node2D

@export var pipe_scene: PackedScene

const GAME_HEIGHT := 720.0
const PIPE_SPACING := 600.0
const PIPE_COUNT := 5
const GAP_CENTER := 360.0
const GAP_VARIATION := 80.0

var score := 0
var game_over := false
var pipes: Array = []


func _ready():
	# Signals
	$Bird.area_entered.connect(_on_bird_area_entered)
	$Bird.died.connect(_on_bird_died)

	# UI
	$UI/ScoreLabel.text = "0"
	$UI/GameOverLabel.visible = false

	# Music
	if $GameMusic:
		$GameMusic.play()

	_spawn_initial_pipes()


func _spawn_initial_pipes():
	var start_x = 1280 + 200

	for i in range(PIPE_COUNT):
		var pipe = pipe_scene.instantiate()
		pipe.position.x = start_x + i * PIPE_SPACING
		pipe.position.y = _random_gap_y()
		add_child(pipe)
		pipes.append(pipe)


func _process(_delta):
	if game_over:
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


func _on_bird_area_entered(area: Area2D):
	if game_over:
		return

	var pipe = area.get_parent()

	if area.is_in_group("pipe"):
		if $HitSound:
			$HitSound.play()
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

	if $HitSound:
		$HitSound.play()
	_end_game()


func _end_game():
	game_over = true
	$UI/GameOverLabel.visible = true

	# Music switch
	if $GameMusic:
		$GameMusic.stop()
	if $GameOverMusic:
		$GameOverMusic.play()

	get_tree().paused = true
