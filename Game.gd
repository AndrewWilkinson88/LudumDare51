extends Node

class_name Game

var NUM_ENCOUNTERS = 5

var encounterPools:Array
var encounters:Array

var _curDeckDef:DeckDef

var _battleScene:Resource
var _shopScene:Resource

var _curBattle
var _curShop
var _curEncounterLevel:int
var _curPlayerHealth:int
var _playerAttackBonus:int
var _playerPowerup:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_curEncounterLevel = 0
	_curPlayerHealth = 200
	_setupEncounters()
	_setupDefaultDeck()
	
	_battleScene = load("res://BattleScene.tscn")
	_shopScene = load("res://Shop.tscn")
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
	move_child(_curBattle, 0)
	_curBattle.init(_curDeckDef, _curPlayerHealth, _playerAttackBonus, _playerPowerup, encounters[_curEncounterLevel], _curEncounterLevel+1)
	_curBattle.connect("battle_ended", self, "_handleBattleEnded")
	
func _showShop():
	_curShop = _shopScene.instance()
	var tweenObj = _curShop.get_node("ShopContainer")
	tweenObj.position.y = -900
	add_child(_curShop);
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(tweenObj, "global_position", Vector2(0,0), 1)
	tween.tween_callback(self, "_removeBattleScene")

func _removeBattleScene():
	_curShop.get_node("ShopContainer/items/health").connect("pressed", self, "_healthPressed")
	_curShop.get_node("ShopContainer/items/attack").connect("pressed", self, "_attackPressed")
	_curShop.get_node("ShopContainer/items/powerup").connect("pressed", self, "_powerupPressed")
	remove_child(_curBattle)

func _healthPressed():
	_removeShopSignalsAndTween()
	_curPlayerHealth += 50
	_loadNextBattle()

func _attackPressed():
	_removeShopSignalsAndTween()
	_playerAttackBonus += 5
	_loadNextBattle()
	
func _powerupPressed():
	_removeShopSignalsAndTween()
	_playerPowerup = true
	_loadNextBattle()

func _removeShopSignalsAndTween():
	_curShop.get_node("ShopContainer/items/health").disconnect("pressed", self, "_healthPressed")
	_curShop.get_node("ShopContainer/items/attack").disconnect("pressed", self, "_attackPressed")
	_curShop.get_node("ShopContainer/items/powerup").disconnect("pressed", self, "_powerupPressed")
	var tweenObj = _curShop.get_node("ShopContainer")
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(tweenObj, "global_position", Vector2(0,-900), 1)
	tween.tween_callback(self, "_removeShopScene")

func _removeShopScene():
	remove_child(_curShop)

func _handleBattleEnded(playerHealth:int):
	_playerPowerup = false
	_curPlayerHealth = playerHealth
	_curBattle.disconnect("battle_ended", self, "_handleBattleEnded")	
	if _curPlayerHealth <= 0:
		get_tree().change_scene("res://DefeatScreen.tscn")
#		remove_child(_curBattle)
#		var defeatScreenDef = load("res://DefeatScreen.tscn")
#		var defeatScreen = defeatScreenDef.instance()
#		add_child(defeatScreen)
	elif _curEncounterLevel < NUM_ENCOUNTERS-1:
		_curEncounterLevel += 1
		#_loadNextBattle()
		_showShop()
	else:
		get_tree().change_scene("res://VictoryScreen.tscn")
#		remove_child(_curBattle)
#		var victoryScreenDef = load("res://VictoryScreen.tscn")
#		var victoryScreen = victoryScreenDef.instance()
#		add_child(victoryScreen)
