
extends "res://Scripts/Item.gd"

func _ready():
	suspicion = 4

func update_choices(choices):
	choices["haveInvitation"] = true
