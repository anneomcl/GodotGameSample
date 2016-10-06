extends Node

var panelNode
var isDialogueEvent = false
var myStory = { }
var initStory
var currDialogue
var currChoices = []
var isChoice = false
var isChoiceDialogue = false
var isEnd = false
var events = { }
var choices = { }

#TO-DO: Keep another file of "story flags" indicating
#actions player has done, use these to dictate how we should look up events
#and make an event handler with functions to decide what to
#return here based on the file
#TO-DO: Write truth values changed in dialogue processor back to this file
#returns the key to the initial dialogue branch

#Default path will always be "eventTarget" : <Target> : "Start" : ...
func choose_dialogue_branch(target):
	var possibleBranches = look_up_event(target)
	var branch = choose_dialogue(possibleBranches, choices)
	if(branch != null):
		return branch
	elif(!possibleBranches["Start"]["Flag"]):
		possibleBranches["Start"]["Flag"] = true
		return possibleBranches["Start"]["Name"]
	else:
		possibleBranches["Repeat"]["Flag"] = true
		return possibleBranches["Repeat"]["Name"]

func choose_dialogue(possibilities, choices):
	for item in possibilities:
		if(item != "Start" and item != "Repeat"):
			if(choices[possibilities[item]["Flag"]]):
				return possibilities[item]["Name"]
	return null

func look_up_event(target):
	return events["eventTarget"][target]

func load_file_as_JSON(path, target):
    var file = File.new()
    file.open(path, file.READ)
    var content = (file.get_as_text())
    target.parse_json(content)
    file.close()

func lock_next_button(isHidden):
	panelNode.get_node("Button").set_hidden(isHidden)

func isInChoiceMode():
	return panelNode.get_node("Button").is_hidden()

func get_choices():
	currChoices = []
	for item in currDialogue:
		if(typeof(item) != TYPE_STRING and item.has("linkPath")):
			currChoices.append(item)
	lock_next_button(true)

#TO-DO: Allow players to use arrow keys/joystick instead of buttons to select options
#TO-DO: Allow players to use number keys to quickly select options
#TO-DO: Make an options menu to toggle dialogue options and input
#TO-DO: Resize dialogue box and buttons based on screen, not magic numbers
#TO-DO: Make validation script to make sure no choices or dialogue goes outside box
func display_choices(text):
	for i in range(0, currChoices.size()):
		var choiceButton = Button.new()
		choiceButton.set_name("ChoiceButton" + str(i))
		panelNode.add_child(choiceButton)
		choiceButton.set_pos(Vector2(10, 10 + 75*i))
		choiceButton.set_size(Vector2(580, 50))
		choiceButton.connect("pressed", self, "_on_button_pressed", [choiceButton])
		
		var choiceLabel = Label.new()
		choiceLabel.set_name("ChoiceLabel" + str(i))
		panelNode.get_node("ChoiceButton" + str(i)).add_child(choiceLabel)
		choiceLabel.set_pos(Vector2(10, 10))
		choiceLabel.set_size(Vector2(580, 50))
		choiceLabel.set_autowrap(true)
		choiceLabel.set_text(currChoices[i]["option"])

func clear_choices(shouldClear):
	lock_next_button(false)
	if(panelNode.get_child_count() > 2):
		for i in range(0, currChoices.size()):
			var button = panelNode.get_node("ChoiceButton" + str(i))
			if(button != null):
				if(shouldClear):
					button.free()
				else:
					button.hide()
			else:
				break

func set_choice_values():
	var newLinkType = get_link_type(currDialogue[1])
	if(newLinkType == "divert"):
		isChoice = false
		isChoiceDialogue = false
	if(newLinkType == "linkPath" and isChoiceDialogue):
		isChoice = true
		isChoiceDialogue = false
	elif(newLinkType == "linkPath" and !isChoiceDialogue):
		isChoice = true
		isChoiceDialogue = true

func set_next_dialogue(target):
	if !("isEnd" in currDialogue[1]):
		var linkType = get_link_type(currDialogue[1])
		if(linkType == "divert"):
			currDialogue = initStory[currDialogue[1]["divert"]]["content"]
		elif(linkType == "linkPath" and isChoiceDialogue):
			get_choices()
		elif(linkType == "linkPath" and !isChoiceDialogue):
			currDialogue = initStory[currDialogue[get_user_choice(target) + 1]["linkPath"]]["content"]
		set_choice_values()
	else:
		isEnd = true
		get_node("../Player/KinematicBody2D").canMove = true
		panelNode.set_hidden(true)

func get_user_choice(target):
	var buttonName = target.get_name()
	var id = buttonName.to_int()
	return id
	
func get_link_type(dialogue):
	var linkType
	if dialogue.has("divert"):
		linkType = "divert"
	elif dialogue.has("linkPath"):
		linkType = "linkPath"
	return linkType

func _on_button_pressed(target):
	if(isEnd):
		panelNode.hide()
	var textToShow = ""
	clear_choices(!(isChoice and !isChoiceDialogue))
	set_next_dialogue(target)
	if(isChoice and !isChoiceDialogue):
		display_choices(textToShow)
	else:
		textToShow = currDialogue[0]
	panelNode.get_node("Label").set_text(textToShow)

func init_dialogue(target):
	
	isDialogueEvent = false
	initStory = null
	currDialogue = null
	currChoices = []
	isChoice = false
	isChoiceDialogue = false
	isEnd = false
	
	get_node("../" + target).update_choices(choices)
	target = choose_dialogue_branch(target)
	
	panelNode.show()
	
	initStory = myStory["data"][target]
	currDialogue = initStory[initStory["initial"]]["content"]
	if currDialogue[1] != null:
		if currDialogue[1].has("divert"):
			isChoice = false
			isChoiceDialogue = false
		if currDialogue[1].has("linkPath"):
			isChoice = true
			isChoiceDialogue = true
	panelNode.get_node("Label").set_text(currDialogue[0])

func _ready():
	set_process_input(true)
	
	load_file_as_JSON("Narrative/storyTest.json", myStory)
	load_file_as_JSON("Narrative/events.json", events)
	load_file_as_JSON("Narrative/choices.json", choices)
	
	panelNode = get_node("../CanvasLayer/Panel")
	
	var initButton = panelNode.get_node("Button")
	initButton.connect("pressed", self, "_on_button_pressed", [initButton])
	
	if(panelNode.is_visible()):
		panelNode.hide()