extends Node2D

class_name Card

signal play_card(card)

var _cardDef
var _pickedPicross:Texture

var _cardBorder:Sprite
var _cardImage:Sprite

var _picross:PicrossPuzzle

func _test(card):
	print("card name = " + card._cardDef.cardName)

func _init(cardDef):
	randomize()
	#connect("play_card", self, "_test")	
	_cardDef = cardDef
	if _cardDef.picrossPool.size() > 0:		
		_pickedPicross = _cardDef.picrossPool[randi() % _cardDef.picrossPool.size()]
	_cardBorder = Sprite.new()
	#_cardBorder.centered = false
	_cardBorder.scale.x = .08
	_cardBorder.scale.y = .08
	_cardBorder.texture = _cardDef.borderArt
	
	_cardImage = Sprite.new()
	#_cardImage.centered = false
	#_cardImage.position.x = 10
	_cardImage.position.y = -30
	_cardImage.scale.x = .2
	_cardImage.scale.y = .2
	_cardImage.texture = _cardDef.cardArt	
	add_child(_cardImage)
	add_child(_cardBorder)
	
	#set_size(_cardBorder.get_rect().size * 10)
	
	var title:Label = Label.new()
	title.set_size(Vector2(100,10))
	title.valign = title.VALIGN_CENTER
	title.align = title.ALIGN_CENTER
	title.text = cardDef.cardName
	title.set_position(Vector2(-50,14))
	add_child(title)
	#connect("pressed", self, "_button_pressed")
	
	_picross = PicrossPuzzle.new(_pickedPicross)

func getPuzzle():
	return _picross
	
func getCardDef():
	return _cardDef
	
var mouseDown = false
func _input(event):
	if  (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if(event.pressed and _cardBorder.get_rect().has_point(_cardBorder.to_local(event.position))):	
			print("mouse down!")
			mouseDown = true;
		elif ( !event.pressed and _cardBorder.get_rect().has_point(_cardBorder.to_local(event.position))):
			print("mouse up!")
			mouseDown = false;
			emit_signal("play_card", self)
		else :
			mouseDown = false;
	pass
