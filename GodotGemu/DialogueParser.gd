extends Node

var myStory = { }
var initStory
var currDialogue
var currChoices = []
var isChoice = false
var isChoiceDialogue = false

func init_dialogue():
	load_file_as_JSON("Narrative/storyTest.json", myStory)
	initStory = myStory["data"]["stitches"]
	currDialogue = initStory[myStory["data"]["initial"]]["content"]
	if currDialogue[1] != null:
		if currDialogue[1].has("divert"):
			isChoice = false
			isChoiceDialogue = false
		if currDialogue[1].has("linkPath"):
			isChoice = true
			isChoiceDialogue = true
	get_node("Panel").get_node("Label").set_text(currDialogue[0])

func load_file_as_JSON(path, target):
    var file = File.new()
    file.open(path, file.READ)
    var content = (file.get_as_text())
    target.parse_json(content)
    file.close()

func lock_next_button(isHidden):
	get_node("Panel").get_node("Button").set_hidden(isHidden)

func isInChoiceMode():
	return get_node("Panel").get_node("Button").is_hidden()

func get_choices():
	currChoices = []
	for item in currDialogue:
		if(typeof(item) != TYPE_STRING and item.has("linkPath")):
			currChoices.append(item)
	lock_next_button(true)

func display_choices(text):
	for i in range(0, currChoices.size()):
		var choiceButton = Button.new()
		choiceButton.set_name("ChoiceButton" + str(i))
		get_node("Panel").add_child(choiceButton)
		choiceButton.set_pos(Vector2(10, 10 + 75*i))
		choiceButton.set_size(Vector2(550, 25))
		choiceButton.connect("pressed", self, "_on_button_pressed", [choiceButton])
		
		var choiceLabel = Label.new()
		choiceLabel.set_name("ChoiceLabel" + str(i))
		get_node("Panel").get_node("ChoiceButton" + str(i)).add_child(choiceLabel)
		choiceLabel.set_pos(Vector2(10, 10))
		choiceLabel.set_text(currChoices[i]["option"])

func clear_choices(shouldClear):
	lock_next_button(false)
	if(get_node("Panel").get_child_count() > 2):
		for i in range(0, currChoices.size()):
			var button = get_node("Panel").get_node("ChoiceButton" + str(i))
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
	if !("isEnd" in currDialogue):
		var linkType = get_link_type(currDialogue[1])
		if(linkType == "divert"):
			currDialogue = initStory[currDialogue[1]["divert"]]["content"]
		elif(linkType == "linkPath" and isChoiceDialogue):
			get_choices()
		elif(linkType == "linkPath" and !isChoiceDialogue):
			currDialogue = initStory[currDialogue[get_user_choice(target) + 1]["linkPath"]]["content"]
		set_choice_values()
	else:
		pass

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
	var textToShow = ""
	clear_choices(!(isChoice and !isChoiceDialogue))
	set_next_dialogue(target)
	if(isChoice and !isChoiceDialogue):
		display_choices(textToShow)
	else:
		textToShow = currDialogue[0]
	get_node("Panel").get_node("Label").set_text(textToShow)

func _ready():
	set_process_input(true)
	init_dialogue()
	var initButton = get_node("Panel").get_node("Button")
	initButton.connect("pressed", self, "_on_button_pressed", [initButton])