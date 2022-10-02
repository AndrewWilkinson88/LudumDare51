extends HBoxContainer

class_name PlayerHand

var cards:Array

# Called when the node enters the scene tree for the first time.
func _ready():
	cards = []
	pass # Replace with function body.

func addCard(cardDef, battleScene):	
	var card = Card.new(cardDef)
	card.connect("play_card", battleScene ,"_on_card_clicked")
	
	card.set_position(Vector2(cards.size() * 120 + 60, 100))
	card.set_rotation( - PI / 16.0 + cards.size() * (PI / 32.0))
	
	add_child(card)
	
	cards.append(card)
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
		cards[i].set_position(Vector2(i * 120 + 60, 100))
		cards[i].set_rotation( - PI / 16.0 + i * (PI / 32.0))
	pass

func cardCount():
	return cards.size()
