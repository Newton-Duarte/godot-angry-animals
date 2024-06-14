extends Node

var attempts: int = 0
var cups_hit: int = 0
var total_cups: int = 0
var level_number: int = 1

func _ready():
	total_cups = get_tree().get_nodes_in_group("cup").size()
	level_number = ScoreManager.get_level_selected()
	SignalManager.attempt_made.connect(on_attempt_made)
	SignalManager.cup_destroyed.connect(on_cup_destroyed)

func on_attempt_made() -> void:
	attempts += 1
	SignalManager.score_updated.emit(attempts)

func on_cup_destroyed() -> void:
	cups_hit += 1
	if cups_hit == total_cups:
		SignalManager.level_complete.emit()
		ScoreManager.set_score_for_level(attempts, str(level_number))
