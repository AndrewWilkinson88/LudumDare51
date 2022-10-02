extends Resource

class_name DeckDef

var cards:Array

func _init(cards = []):
	cards = []
	for c in cards:
		cards.append(c)

func addCard(card):
	cards.append(card)
