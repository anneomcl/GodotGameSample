extends Node

var choices = { }

func get_choice(key):
	return choices[key]

func _ready():
	#load_JSON_as_file("Narrative/choices.json", choices)
	pass
