extends TextureRect
class_name Card

signal play_card(card)

var _cardDef
var _pickedPicross:Texture

var _cardBorder:TextureRect
var _cardImage:Sprite

var _picross:PicrossPuzzle

func _test(card):
	print("card name = " + card._cardDef.cardName)

func init(cardDef):
	randomize()
	_cardDef = cardDef
	if _cardDef.picrossPool.size() > 0:		
		_pickedPicross = _cardDef.picrossPool[randi() % _cardDef.picrossPool.size()]
	self.texture = _cardDef.borderArt
	_picross = PicrossPuzzle.new(_pickedPicross)

func getPuzzle():
	return _picross
	
func getTexture():
	return _pickedPicross
	
func getCardDef():
	return _cardDef

func _on_Button_pressed():
	emit_signal("play_card", self)
	pass
