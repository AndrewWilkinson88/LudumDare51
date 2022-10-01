extends Node2D

class_name PicrossPuzzle

var THRESHOLD : float = .1
var UI_OFFSET : int = 120

var gamefield : Node2D

# Texture for the input puzzle
var curPuzzleTexture : Texture

var cellTexture : Texture
var yesTexture : Texture
var noTexture : Texture

var font : DynamicFont

#Holds the Y and X picross arrays.  IE if the image were 0011001100 the array would hold (2,2)
var curPuzzlePicrossY
var curPuzzlePicrossX

var picrossField

#Width and heigh of puzzle
var puzzleWidth :int
var puzzleHeight :int 

# Called when the node enters the scene tree for the first time.
func _ready():
	self.scale.x = 2
	self.scale.y = 2
	font = DynamicFont.new()	
	font.font_data = load("res://fonts/rainyhearts.ttf")
	font.size = 32
	font.extra_spacing_bottom = -3
	font.extra_spacing_top = -3
	cellTexture  = load("res://picross/cell.png")
	yesTexture  = load("res://picross/picrosspositive.png")
	noTexture  = load("res://picross/x.png")
	
	createPicrossPuzzle("res://picross/smiley.png")
	pass # Replace with function body.
	
#Load and setup a picross puzzle by name
func createPicrossPuzzle(imageName):
	curPuzzleTexture = load(imageName)
	var sprite = Sprite.new()
	sprite.texture = curPuzzleTexture
	sprite.position.x = 10
	sprite.position.y = 10
	
	var image : Image = curPuzzleTexture.get_data()
	puzzleWidth = image.get_width()
	puzzleHeight = image.get_height()
	
	var c : Color
	var chainCounter :int  = 0
	var firstPerLine :bool
	
	curPuzzlePicrossX = []
	curPuzzlePicrossY = []
	
	image.lock()
	
	# for the Y picross values (the ones going across the columns) we loop through x then y
	for x in puzzleWidth:
		curPuzzlePicrossY.append( [])
		firstPerLine = true
		for y in puzzleHeight:
			# Get the pixel value at this x,y and check if its within our threshold.
			# If its within our threshold we add to our current chainCount (current picross value)
			c = image.get_pixel (x, y )
			if c.a >= THRESHOLD :
				chainCounter +=1
			# If we have a chainCount of at least 1 and we're either not within threshold 
			# or at the end of line then we're ready to create a full entry for this picross value
			if chainCounter > 0 && (c.a < THRESHOLD || y == puzzleHeight-1) :
				curPuzzlePicrossY[x].append( chainCounter)
				firstPerLine = false
				chainCounter = 0
	
	chainCounter = 0
	
	for y in puzzleHeight:
		curPuzzlePicrossX.append( [])
		firstPerLine = true
		for x in puzzleWidth:
			c = image.get_pixel (x, y )
			if c.a >= THRESHOLD :
				chainCounter +=1
			if chainCounter > 0 && (c.a < THRESHOLD || x == puzzleWidth-1) :
				curPuzzlePicrossX[y].append( chainCounter)
				firstPerLine = false
				chainCounter = 0
			
	image.unlock()
		
	_generateGamefield()
	_generatePicrossText()
	pass

func _generateGamefield():
	gamefield = Node2D.new()
	gamefield.position.x = UI_OFFSET
	gamefield.position.y = UI_OFFSET
	add_child(gamefield)
	picrossField = []
	for x in puzzleWidth:
		picrossField.append([])
		for y in puzzleHeight:
			var cell = PicrossCell.new()
			picrossField[x].append(cell)
			cell.setup(cellTexture, yesTexture, noTexture)
			cell.position.x = x * cellTexture.get_width()
			cell.position.y = y * cellTexture.get_height()
			gamefield.add_child(cell)
	pass

func _generatePicrossText():
	
	for x in puzzleWidth:
		var label = Label.new()
		label.set("custom_fonts/font", font);
		label.set_size(Vector2(cellTexture.get_width(), UI_OFFSET-3))
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_BOTTOM
		add_child(label)
		label.set_position(Vector2(UI_OFFSET + x * cellTexture.get_width(), 0))	
		for y in curPuzzlePicrossY[x].size():
			label.text += str(curPuzzlePicrossY[x][y]) 
			if(y != curPuzzlePicrossY[x].size()-1):
				label.text += "\n"
	
	for y in puzzleHeight:
		var label = Label.new()
		label.set("custom_fonts/font", font);
		label.set_size(Vector2(UI_OFFSET-3, cellTexture.get_height()))
		label.align = Label.ALIGN_RIGHT
		label.valign = Label.VALIGN_CENTER
		add_child(label)
		label.set_position( Vector2(0,UI_OFFSET + y * cellTexture.get_height()))
		for x in curPuzzlePicrossX[y].size():
			label.text += str(curPuzzlePicrossX[y][x])
			if(x != curPuzzlePicrossX[y].size()-1):
				label.text +=  "  "
	
	pass

var leftButtonDown : bool = false
var dragType = PicrossCell.CELL_STATE.UNDEFINED
var rightButtonDown : bool = false

func _input(event):
	if event is InputEventMouse:
		var pos = gamefield.to_local(event.position)
		var x :int = pos.x / cellTexture.get_width()
		var y :int = pos.y / cellTexture.get_height()
		var isValidCell = x >= 0 and x < puzzleWidth and y >= 0 and y < puzzleHeight
		
		if  (event is InputEventMouseButton):
			if  (event.button_index == BUTTON_LEFT and event.pressed and isValidCell):
				leftButtonDown = true
				dragType = (picrossField[x][y].getState() + 1) % 3
			elif(event.button_index == BUTTON_LEFT and not event.pressed): 
				leftButtonDown = false
						
			if  (event.button_index == BUTTON_RIGHT and event.pressed):     
				rightButtonDown = true
			elif(event.button_index == BUTTON_RIGHT and not event.pressed): 
				rightButtonDown = false
		
		if leftButtonDown and isValidCell:
			picrossField[x][y].setState(dragType)
		if rightButtonDown and isValidCell:
			picrossField[x][y].setState(PicrossCell.CELL_STATE.NO)
	pass

