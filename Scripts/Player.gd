extends KinematicBody2D

var speed = 3
var move_direction = Vector2(0, 0)
var target

var inventory = []

var canMove = true
var canInteract = false

func _ready():
    set_process_input(true)
    set_fixed_process(true)

func _fixed_process(delta):
	if(canMove):
		move_player()
		
func _input(event):
	if(canInteract and event.is_action_pressed("interact")):
		get_node("../../DialogueParser").init_dialogue(target.get_name())
		canMove = false
		if(target.is_in_group("Item") and inventory.find(target.get_name()) < 0):
			inventory.append(target.get_name())
			print(inventory) #TODO: delete this
			print(target.suspicion)

func move_player():
	move_direction = Vector2(0,0)
	if(Input.is_key_pressed(KEY_A)):
		move_direction += Vector2(-1, 0)
	if(Input.is_key_pressed(KEY_D)):
		move_direction += Vector2(1, 0)
	if(Input.is_key_pressed(KEY_W)):
		move_direction += Vector2(0, -1)
	if(Input.is_key_pressed(KEY_S)):
		move_direction += Vector2(0, 1)
	move(move_direction.normalized() * speed)

func _on_Area2D_body_enter(body, obj):
	if(body.get_parent().get_name() == "Player"):
		canInteract = true
		target = obj
	
func _on_Area2D_body_exit(body, obj):
	if(body.get_parent().get_name() == "Player"):
		canInteract = false
		target = null