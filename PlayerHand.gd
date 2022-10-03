extends HBoxContainer

class_name PlayerHand

var card
var cards:Array

func _init():
	card = load("res://Card.tscn")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	cards = []
	pass # Replace with function body.

func addCard(cardDef, battleScene):	
	var new_card = card.instance()
	new_card.init(cardDef)
	new_card.connect("play_card", battleScene ,"_on_card_clicked")
	add_child(new_card)
	cards.append(new_card)
	pass

func removeCard(card, battleScene):
	card.disconnect("play_card", battleScene ,"_on_card_clicked")
	remove_child(card)
	for i in cards.size():
		if cards[i] == card:
			cards.remove(i)
			break
	respace()	
	pass

func respace():
	for i in cards.size():
		#cards[i].set_position(Vector2(i * 120 + 60, 100))
		#cards[i].set_rotation( - PI / 16.0 + i * (PI / 32.0))
		pass
	pass

func cardCount():
	return cards.size()
