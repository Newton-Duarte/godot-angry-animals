extends Control

const MAIN = preload("res://scenes/main.tscn")

@onready var level_label = %LevelLabel
@onready var attempts_label = %AttemptsLabel
@onready var vb_level_complete = %VBLevelComplete
@onready var press_space_label = %PressSpaceLabel
@onready var level_complete_music = $LevelCompleteMusic
@onready var press_space_label_timer = $PressSpaceLabelTimer

func _ready():
	vb_level_complete.hide()
	press_space_label.hide()
	level_label.text = "Level: %s" % str(ScoreManager.get_level_selected())
	update_attempts_label(0)
	SignalManager.score_updated.connect(update_attempts_label)
	SignalManager.level_complete.connect(on_level_complete)

func _process(_delta):
	if press_space_label.visible:
		if Input.is_action_just_pressed("drag"):
			get_tree().change_scene_to_packed(MAIN)

func update_attempts_label(attempts: int) -> void:
	attempts_label.text = "Attempts: %s" % str(attempts)

func on_level_complete() -> void:
	level_complete_music.play()
	vb_level_complete.show()
	press_space_label_timer.start()

func _on_press_space_label_timer_timeout():
	press_space_label.show()
