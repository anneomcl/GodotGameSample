extends KinematicBody2D

var speed = 3
var move_direction

var canMove = true
var canInteract = false

func _ready():
    set_process_input(true)
    set_fixed_process(true)

	#TO-DO: Connect all area2D nodes in a scene to this function
	#to determine if the body is in or out of range for interaction
    var area2DNode = get_node("../../Professor/Area2D")
    area2DNode.connect("body_enter", self, "_on_Area2D_body_enter")
    area2DNode.connect("body_exit", self, "_on_Area2D_body_exit")

func _fixed_process(delta):
	handle_interactions()
	if(canMove):
		move_player()
		
func handle_interactions():
	#TO-DO: Have generic InteractionComplete flag set canMove
	if(get_node("../../DialogueParser").isEnd):
		canMove = true
	
	if(canInteract and Input.is_key_pressed(KEY_E)):
		#TODO: Generic DoInteraction() based on "body" from onArea2DBodyEnter
		#TODO: Choose dialogue based on character and events
		get_node("../../DialogueParser").init_dialogue_system()
		canMove = false

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

func _on_Area2D_body_enter(body):
	canInteract = true
	
func _on_Area2D_body_exit(body):
	canInteract = false