extends Node
class_name BattleScene

export (PackedScene) var monster_scene
export (PackedScene) var monster_action
enum action_type {ACTION_ATTACK, ACTION_IDLE, ACTION_POWERUP, ACTION_CHANGE_WEAKNESS}
enum attack_type {ATTACK_FIRE, ATTACK_AIR, ATTACK_ICE, ATTACK_PHYSICAL}
enum weakness_type {WEAKNESS_FIRE, WEAKNESS_AIR, WEAKNESS_ICE, WEAKNESS_LIGHT}

var player_health
var player_deck
var player_hand
var current_monster: Sprite
var monster_container
var player_health_text
var _playerAttackBonus
var _playerPowerup
var monster_health_text
var monster_actions
var level_text

#var monster_init
var monster_name
var monster_timer

var picross_container
var cur_card
var player_hand_container
var victory_label

#var playerDeckDef
var playerDeck
var arrow_image

signal player_attack
signal battle_ended

func init(playerDeckDef, playerHealth, playerAttackBonus, playerPowerup, encounter, encounterLevel):
	player_health = playerHealth
	_playerAttackBonus = playerAttackBonus
	_playerPowerup = playerPowerup
	
	if playerPowerup:
		$PowerUp.disabled = false
		$PowerUp.connect("pressed", self, "_usePowerup")

	if playerAttackBonus > 0:
		$PlayerSide/PlayerMargins/PlayerLayout/GridContainer/VBoxContainer/HBoxContainer2/Label_PlayerAttack.text = str(playerAttackBonus)
	else :
		$PlayerSide/PlayerMargins/PlayerLayout/GridContainer/VBoxContainer/HBoxContainer2.visible = false

	#Monster Stuff
	monster_container = $EnemySide/MarginContainer/GridContainer/MonsterContainer
	monster_health_text = $EnemySide/MarginContainer/GridContainer/VBoxContainer/HBoxContainer/Label_monster_health
	monster_actions = $EnemySide/MarginContainer/GridContainer/MonsterActions
	arrow_image = Image.new()
	arrow_image.load("res://UI_Art/Action_Arrow.png")

	#Player Stuff
	player_health_text = $PlayerSide/PlayerMargins/PlayerLayout/GridContainer/VBoxContainer/HBoxContainer/Label_PlayerHealth
	picross_container = $PlayerSide/PlayerMargins/PlayerLayout/GridContainer/PicrossContainer
	player_hand_container = $PlayerSide/PlayerMargins/PlayerLayout/PlayerHandContainer
	monster_name = $EnemySide/MarginContainer/GridContainer/VBoxContainer/MonsterName
	level_text = $EnemySide/MarginContainer/GridContainer/VBoxContainer/level_text
	victory_label = $VictoryDefeatLabel
	level_text.text = "Level " + str(encounterLevel)
	current_monster = monster_scene.instance()
	
	monster_container.add_child(current_monster)
	var sprite_rect = monster_container.get_rect()
	self.connect("player_attack", current_monster, "take_damage")
	current_monster.connect("monster_attack", self, "player_take_damage")
	current_monster.connect("monster_queue_change", self, "update_monster_queue")
	current_monster.connect("monster_death", self, "_onMonsterDeath")
	current_monster.init(encounter)
	monster_timer = current_monster.get_node("MonsterActionTimer")
	monster_name.text = encounter.encounterName
	current_monster.position.x = monster_container.rect_position.x + sprite_rect.size.x / 2
	current_monster.position.y = monster_container.rect_position.y + sprite_rect.size.y / 2
	
	#TODO get players actual current deck
	playerDeck = DeckInstance.new(playerDeckDef)
	
	for i in 3:
		player_hand_container.addCard(playerDeck.draw(), self)
	
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time( 10 )
	timer.connect("timeout",self,"_tryDrawCard") 
	timer.start()
	pass 

func _usePowerup():
	if(cur_card != null ):
		cur_card.getPuzzle()._win()
		$PowerUp.disabled = true

func _tryDrawCard():
	if player_hand_container.cardCount() < 5:
		player_hand_container.addCard(playerDeck.draw(), self)


func _process(delta):
	monster_health_text.text = str(current_monster.remaining_health)
	player_health_text.text = str(player_health)
	if(monster_actions.get_child_count() != 0):
		monster_actions.get_child(0).value = 10-monster_timer.time_left
		pass
	pass

func player_take_damage(damage):
	player_health -= damage
	
	if player_health <= 0:
		victory_label.text = "Defeat"
		_playVictoryDefeat()
	pass
func _playVictoryDefeat():
	victory_label.visible = true
	victory_label.modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(victory_label, "rect_scale", Vector2(2,2), 1)
	tween.parallel().tween_property(victory_label, "modulate", Color(1,1,1,1), 1)
	tween.tween_callback(self, "_onBattleEnded");
	
func _onBattleEnded():
	emit_signal("battle_ended", player_health)

func _onMonsterDeath():
	current_monster.disconnect("monster_death", self, "_onMonsterDeath")
	_playVictoryDefeat()
	pass

func update_monster_queue(action_queue):
	for n in monster_actions.get_children(): 
		monster_actions.remove_child(n)
		n.queue_free()

	for x in action_queue:
		var new_action = monster_action.instance()
		var label = new_action.get_node("Label_action")
		match(x):
			action_type.ACTION_IDLE:
				label.text = "Idle"
			action_type.ACTION_ATTACK:
				label.text = "Attack"
			action_type.ACTION_CHANGE_WEAKNESS:
				label.text = "ChDef"
			action_type.ACTION_POWERUP:
				label.text = "PwrUp"
		monster_actions.add_child(new_action)
		var arrow = TextureRect.new()
		arrow.texture = load("res://UI_Art/Action_Arrow.png")
		arrow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		monster_actions.add_child(arrow)
	pass

func _on_card_clicked(card):
	if cur_card != null :
		var oldPuzzle = cur_card.getPuzzle()
		picross_container.remove_child(oldPuzzle)
		oldPuzzle.disconnect("complete_puzzle", self, "_on_picross_complete")
	cur_card = card
	var puzzle = card.getPuzzle()
	picross_container.add_child(puzzle)
	puzzle.connect("complete_puzzle", self, "_on_picross_complete")
	pass

func _on_picross_complete():
	if cur_card.getCardDef() is AttackCardDef:
		_animateAttack(cur_card)
	picross_container.remove_child( cur_card.getPuzzle())
	cur_card.getPuzzle().disconnect("complete_puzzle", self, "_on_picross_complete")
	player_hand_container.removeCard(cur_card, self);
	playerDeck.discard(cur_card.getCardDef())
	cur_card = null
	pass

func _animateAttack(cur_card):
	var sprite = Sprite.new()
	sprite.scale.x = 20;
	sprite.scale.y = 20;
	sprite.texture = cur_card.getTexture()
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	add_child(sprite)
	sprite.position = picross_container.rect_position + picross_container.rect_scale*picross_container.rect_size/2.0	
	tween.tween_property(sprite, "global_position", current_monster.global_position , .5)
	tween.tween_callback(self, "_triggerDamage", [cur_card]);
	tween.tween_property(sprite, "scale", Vector2(40,40), .5)
	tween.parallel().tween_property(sprite, "modulate", Color(1,1,1,0), .5)	
	tween.tween_callback(self, "_removeSprite", [sprite]);
	#tween.interpolate_callback(self, 2, "_triggerDamage", sprite)

func _removeSprite(sprite):
	remove_child(sprite)

func _triggerDamage(cur_card):
	emit_signal("player_attack", cur_card.getCardDef().attackType,  cur_card.getCardDef().damage + _playerAttackBonus)

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ENTER:
		_tryDrawCard()
