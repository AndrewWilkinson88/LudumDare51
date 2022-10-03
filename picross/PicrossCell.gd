extends Node2D

class_name PicrossCell

var _cellTexture
var _yesTexture
var _noTexture

var cell
var overlay
var curState = CELL_STATE.UNDEFINED

enum CELL_STATE {UNDEFINED, YES, NO}

func _init(cellTexture, yesTexture, noTexture):
	_cellTexture = cellTexture
	_yesTexture = yesTexture
	_noTexture = noTexture
	
	cell = Sprite.new()
	cell.centered = false
	cell.texture = _cellTexture
	add_child(cell)
	
	overlay = Sprite.new()
	overlay.position.x += 16
	overlay.position.y += 16
	#overlay.centered = false
	overlay.texture = null
	add_child(overlay)
	pass

func getState():
	return curState
	
func setState(cellState):
	if(curState == cellState):
		return false
	curState = cellState
	animateOverlay(cellState)
	#setOverlay(curState)
	return true

func animateOverlay(cellState):
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
#	if(overlay.texture != null):
#		tween.tween_property(overlay, "scale", Vector2(2,2), .25)
#		tween.parallel().tween_property(overlay, "modulate", Color(1,1,1,0), .25)
#		tween.tween_callback(self, "setOverlay", [cellState])
#	else:
	overlay.scale = Vector2(.1,.1)
	overlay.modulate = Color(1,1,1,0)
	setOverlay(cellState)
	tween.tween_property(overlay, "scale", Vector2(1,1), .25)
	tween.parallel().tween_property(overlay, "modulate", Color(1,1,1,1), .25)
	

func setOverlay(cellState ):
	if(cellState == CELL_STATE.UNDEFINED):
		overlay.texture = null
	elif(cellState == CELL_STATE.YES):
		overlay.texture = _yesTexture
	elif(cellState == CELL_STATE.NO):
		overlay.texture = _noTexture
	pass


