extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var picross = PicrossPuzzle.new(load("res://picross/smiley.png"))
	add_child(picross)
	pass # Replace with function body.
