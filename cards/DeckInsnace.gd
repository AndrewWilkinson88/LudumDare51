extends Node2D

class_name DeckInstance

var _deckDef
var _curShuffle
var _discard

func _init(deckDef):
	_deckDef = deckDef	
	_discard = []
	#This makes a copy of all cards in the _deckDef
	_curShuffle = [] + _deckDef.cards
	shuffleDeck()

func shuffleDeck():
	randomize()
	var temp
	for i in _curShuffle.size():
		var pick = randi() % (_curShuffle.size() - i)
		temp  = _curShuffle[i]
		_curShuffle[i] = _curShuffle[i + pick]
		_curShuffle[i+pick] = temp

func discard(card):
	_discard.append(card)

func draw():
	if _curShuffle.size() == 0:
		if _discard.size() != 0:
			_curShuffle += _discard
			_discard = []
			shuffleDeck()	
	var ret = _curShuffle[0]
	_curShuffle.remove(0)
	return ret
