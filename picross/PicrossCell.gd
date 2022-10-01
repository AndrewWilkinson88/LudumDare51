extends Node2D

class_name PicrossCell

var _cellTexture
var _yesTexture
var _noTexture

var cell
var overlay
var curState = CELL_STATE.UNDEFINED

enum CELL_STATE {UNDEFINED, YES, NO}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(cellTexture, yesTexture, noTexture):
	_cellTexture = cellTexture
	_yesTexture = yesTexture
	_noTexture = noTexture
	
	cell = Sprite.new()
	cell.centered = false
	cell.texture = _cellTexture
	add_child(cell)
	
	overlay = Sprite.new()
	overlay.centered = false
	overlay.texture = null
	add_child(overlay)
	pass

func getState():
	return curState
	
func setState(cellState):
	if(curState == cellState):
		return false
	curState = cellState
	setOverlay(curState)
	return true

func setOverlay(cellState ):
	if(cellState == CELL_STATE.UNDEFINED):
		overlay.texture = null
	elif(cellState == CELL_STATE.YES):
		overlay.texture = _yesTexture
	elif(cellState == CELL_STATE.NO):
		overlay.texture = _noTexture
	pass


