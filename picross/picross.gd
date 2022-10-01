extends Node2D

class_name PicrossPuzzle

var THRESHOLD : float = .1

# Texture for the input puzzle
var curPuzzleTexture : Texture

var cellTexture : Texture
var yesTexture : Texture
var noTexture : Texture

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
	cellTexture  = load("res://picross/cell.png")
	yesTexture  = load("res://picross/picrosspositive.png")
	noTexture  = load("res://picross/x.png")
	
	createPicrossPuzzle("res://picross/face2.png")
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
	
	var textToPrint = ""
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
				if !firstPerLine :
					textToPrint += " , "
				textToPrint += str(chainCounter) 
				firstPerLine = false
				chainCounter = 0
		if firstPerLine :
			textToPrint += '-'
		textToPrint += "\n"
	
	print(textToPrint)
	print()
	textToPrint = ""
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
				if !firstPerLine :
					textToPrint += " , "
				textToPrint += str(chainCounter) 
				firstPerLine = false
				chainCounter = 0
		if firstPerLine :
			textToPrint += '-'
		textToPrint += "\n"
		
	print(textToPrint)
	image.unlock()
	
	#add_child(sprite)
	_generateGamefield()
	pass

func _generateGamefield():
	picrossField = []
	for x in puzzleWidth:
		picrossField.append([])
		for y in puzzleHeight:
			var cell = PicrossCell.new()
			picrossField[x].append(cell)
			cell.setup(cellTexture, yesTexture, noTexture)
			cell.position.x = x * cellTexture.get_width()
			cell.position.y = y * cellTexture.get_height()
			add_child(cell)
			
#			if (x + y) % 3 == 0:
#				cell.setOverlay(PicrossCell.CELL_STATE.YES)
#			elif (x + y+1) % 3:
#				cell.setOverlay(PicrossCell.CELL_STATE.NO)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
var leftButtonDown : bool = false
var dragType = PicrossCell.CELL_STATE.UNDEFINED
var rightButtonDown : bool = false

func _input(event):
	if event is InputEventMouse:
		var pos = to_local(event.position)
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

		print ("x : " + str(x) + "   y : " + str(y))
		if leftButtonDown and isValidCell:
			picrossField[x][y].setState(dragType)
		if rightButtonDown and isValidCell:
			picrossField[x][y].setState(PicrossCell.CELL_STATE.NO)
	pass
