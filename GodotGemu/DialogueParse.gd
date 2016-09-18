extends Node

func _on_mouse_click():
	get_node("Panel").get_node("Label").set_text("HELLO!")

func _input(event):
	if(event.type == InputEvent.MOUSE_BUTTON):
		_on_mouse_click()

func _ready():
	set_process_input(true)