extends Node2D

const ANIMAL = preload("res://scenes/animal.tscn")

@onready var animal_start = $AnimalStart

func _ready():
	add_animal()
	SignalManager.player_died.connect(on_player_died)

func add_animal():
	var animal = ANIMAL.instantiate()
	animal.position = animal_start.position
	add_child(animal)

func on_player_died():
	add_animal()
