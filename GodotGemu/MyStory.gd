extends Node

var myStory = {
    "url_key": "vjz9",
    "title": "A Story Where YOUR CHOICES Affect the Outcome But For Real This Time: The Game",
    "updated_at": "2016-09-14T05:58:00Z",
    "created_at": "2016-09-14T05:34:57Z",
    "data": {
        "optionMirroring": true,
        "initial": "helloThereYoungC",
        "editorData": {
            "authorName": "TheHappieCat",
            "textSize": 0,
            "playPoint": "alrightGreatNowW",
            "libraryVisible": true
        },
        "stitches": {
            "okayIUnderstandI": {
                "content": [
                    "Okay, I understand, I hear you-- Ah, wait!\u00a0The form I have here only has two checkboxes, so... Uh... How about we pick one at random?",
                    {
                        "divert": "coinFlipSaysAhhI"
                    }
                ]
            },
            "iSee": {
                "content": [
                    "I see!",
					{
						"divert": "alrightGreatNowW"
					}
                ]
            },
            "lookSorryThatWas": {
                "content": [
                    "Look, sorry, that was kind of a sudden question. And I'm not trying to pressure you into making this decision. It's okay if you don't want to assign yourself to a gender. So, alright, one more time: are you a boy or a girl, or neither?",
                    {
                        "linkPath": "iSee",
                        "ifConditions": null,
                        "notIfConditions": null,
                        "option": "Boy"
                    },
                    {
                        "linkPath": "iSee",
                        "ifConditions": null,
                        "notIfConditions": null,
                        "option": "Girl"
                    },
                    {
                        "linkPath": "okayIUnderstandI",
                        "ifConditions": null,
                        "notIfConditions": null,
                        "option": "Neither"
                    }
                ]
            },
            "anywayEnoughOfTh": {
                "content": [
                    "Anyway, enough of that, are you a boy or a girl?",
                    {
                        "linkPath": "lookSorryThatWas",
                        "ifConditions": null,
                        "notIfConditions": null,
                        "option": "Boy"
                    },
                    {
                        "linkPath": null,
                        "ifConditions": null,
                        "notIfConditions": null,
                        "option": "Girl"
                    }
                ]
            },
            "alrightGreatNowW": {
                "content": [
                    "Alright, great. Now what's your full, legal name?"
                ]
            },
            "ahISeeYoureAGrow": {
                "content": [
                    "Ah, I see, you're a \"grown up\". I, too, am a \"grown up\". Let's talk about stock markets and our ex-wives!",
                    {
                        "divert": "anywayEnoughOfTh"
                    }
                ]
            },
            "helloThereYoungC": {
                "content": [
                    "Hello there, young child or person of other age demographic!",
                    {
                        "linkPath": "ahISeeYoureAGrow",
                        "ifConditions": null,
                        "notIfConditions": null,
                        "option": "You realize that children are no longer the primary demographic for gaming, right?"
                    },
                    {
                        "linkPath": "butOfCourseIAmTh",
                        "ifConditions": null,
                        "notIfConditions": null,
                        "option": "Hello, there! Yes, thank you, I am a child gamer, good to have that acknowledged."
                    },
                    {
                        "pageNum": 1
                    }
                ]
            },
            "coinFlipSaysAhhI": {
                "content": [
                    "Coin flip says... ahh, I won't tell you. I'm just filling out some stupid forms, I'm sure it won't affect you in the future at all.",
                    {
                        "divert": "alrightGreatNowW"
                    }
                ]
            },
            "butOfCourseIAmTh": {
                "content": [
                    "But of course! I am the harbinger of your coming of age, you see! Of all young whippersnappers looking to adventure in the world, and complete\u00a0a little character arc I like to call... adolescence :')",
                    {
                        "divert": "anywayEnoughOfTh"
                    }
                ]
            }
        },
        "allowCheckpoints": false
    }
}

var initStory = myStory["data"]["stitches"]
var currDialogue = initStory[myStory["data"]["initial"]]["content"]
var currChoices = []
var isChoice = false
var isChoiceDialogue = false

func init_dialogue():
	if currDialogue[1] != null:
		if currDialogue[1].has("divert"):
			isChoice = false
			isChoiceDialogue = false
		if currDialogue[1].has("linkPath"):
			isChoice = true
			isChoiceDialogue = true

func get_choices():
	for item in currDialogue:
		if(typeof(item) != TYPE_STRING and item.has("linkPath")):
			currChoices.append(item)

func display_choices(text):
	var id = 0
	for choice in currChoices:
		var choiceButton = Button.new()
		choiceButton.set_name("ChoiceButton" + str(id))
		get_node("Panel").add_child(choiceButton)
		
		print(choiceButton.get_name())
		
		#create button with choice["option"] as a label on it
		text += choice["option"]
		text += "\n"
		id += 1
	currChoices = []
	return text

var userChoice = 1

func set_next_dialogue():
	if currDialogue.size() > 1:
		var linkType
		if(!isChoice):
			if currDialogue[1].has("divert"):
				linkType = "divert"
			elif currDialogue[1].has("linkPath"):
				isChoice = true
				isChoiceDialogue = true
				linkType = "linkPath"
			currDialogue = initStory[currDialogue[1][linkType]]["content"]		
		elif isChoice and !isChoiceDialogue:
			var nextKey = currDialogue[userChoice]["linkPath"]
			currDialogue = initStory[nextKey]["content"]
			isChoice = false
		elif isChoice and isChoiceDialogue:
			get_choices()
			isChoiceDialogue = false

func _on_button_pressed():
	var textToShow = ""
	if(isChoice and !isChoiceDialogue):
		textToShow = display_choices(textToShow)
	elif(isChoice and isChoiceDialogue):
		textToShow = currDialogue[0]
		#get_node("Label").set_text(textToShow)
		#clear_choices()
	else:
		textToShow = currDialogue[0]
		#get_node("Label").set_text(textToShow)
		#clear_choices()
	get_node("Panel").get_node("Label").set_text(textToShow)	
	set_next_dialogue()
		
func _on_mouse_click():
	pass

func _input(event):
	pass
	#if(event.type == InputEvent.MOUSE_BUTTON):
		#_on_mouse_click()

func _ready():
	set_process_input(true)
	init_dialogue()
	get_node("Panel").get_node("Button").connect("pressed", self, "_on_button_pressed")