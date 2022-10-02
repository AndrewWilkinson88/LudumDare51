extends Node

class_name Game

var NUM_ENCOUNTERS = 5

var encounterPools:Array
var encounters:Array

var _curDeckDef:DeckDef

var _battleScene:Resource

var _curBattle
var _curEncounterLevel:int
var _curPlayerHealth:int

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_curEncounterLevel = 0
	_curPlayerHealth = 200
	_setupEncounters()
	_setupDefaultDeck()
	
	_battleScene = load("res://BattleScene.tscn")
	_loadNextBattle()
	
	pass # Replace with function body.

func _setupEncounters():
	encounters = []
	encounterPools = []
	for i in NUM_ENCOUNTERS:
		encounterPools.append([])
	
	var encounterList:EncounterList = load("res://encounters/EncounterList.tres")
	for e in encounterList.encounters:
		for i in e.levels:
			if i < encounterPools.size():
				encounterPools[i].append(e)
				
	for i in NUM_ENCOUNTERS:
		if encounterPools[i].size() < 0:
			print("ERROR!  no encounter possible at this level!")
			continue
		encounters.append( encounterPools[i][randi() % encounterPools[i].size()])

func _setupDefaultDeck():
	_curDeckDef = load("res://cards/DefaultDeck.tres")


func _loadNextBattle():
	_curBattle = _battleScene.instance()
	add_child(_curBattle)
	_curBattle.init(_curDeckDef, _curPlayerHealth, encounters[_curEncounterLevel], _curEncounterLevel+1)
	_curBattle.connect("battle_ended", self, "_handleBattleEnded")	

func _handleBattleEnded(playerHealth:int):
	_curPlayerHealth = playerHealth
	_curBattle.disconnect("battle_ended", self, "_handleBattleEnded")
	remove_child(_curBattle)
	if _curPlayerHealth <= 0:
		#TODO game over
		print("GAME OVER")
	elif _curEncounterLevel < NUM_ENCOUNTERS-1:
		_curEncounterLevel += 1
		_loadNextBattle()
	else:
		#TODO make victory screen
		#print("YOU WIN!")
		var victoryScreenDef = load("res://VictoryScreen.tscn")
		var victoryScreen = victoryScreenDef.instance()
		add_child(victoryScreen)
