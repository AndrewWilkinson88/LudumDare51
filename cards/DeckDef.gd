extends Resource

class_name DeckDef

export(Array, Resource) var cards

func _init():
	cards = []
	for c in cards:
		cards.append(c)

func addCard(card):
	cards.append(card)
