extends Node

const DEFAULT_SCORE: int = 1000
const SCORES_PATH = "user://animals.json"

var level_selected: int = 1
var level_scores: Dictionary = {}

func _ready():
	load_from_disc()

func set_level_selected(level: int) -> void:
	level_selected = level

func get_level_selected() -> int:
	return level_selected

func check_and_add(level: String) -> void:
	if !level_scores.has(level):
		level_scores[level] = DEFAULT_SCORE

func set_score_for_level(score: int, level: String) -> void:
	check_and_add(level)
	if level_scores[level] > score:
		level_scores[level] = score
		save_to_disc()

func get_best_score_for_level(level: String) -> int:
	check_and_add(level)
	return level_scores[level]

func save_to_disc() -> void:
	var file = FileAccess.open(SCORES_PATH, FileAccess.WRITE)
	var scores_json_str = JSON.stringify(level_scores)
	file.store_string(scores_json_str)

func load_from_disc() -> void:
	var file = FileAccess.open(SCORES_PATH, FileAccess.READ)
	if file == null:
		save_to_disc()
	else:
		var file_content = file.get_as_text()
		level_scores = JSON.parse_string(file_content)
