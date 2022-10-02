extends Node
class_name BattleScene

export (PackedScene) var monster_scene
enum action_type {ACTION_ATTACK, ACTION_IDLE, ACTION_POWERUP, ACTION_CHANGE_ATTACK, ACTION_CHANGE_WEAKNESS}
enum attack_type {ATTACK_FIRE, ATTACK_AIR, ATTACK_ICE, ATTACK_PHYSICAL}
enum weakness_type {WEAKNESS_FIRE, WEAKNESS_AIR, WEAKNESS_ICE, WEAKNESS_LIGHT}

var player_health
var player_deck
var player_hand
var current_monster: Sprite
var sprite_container
var player_health_text
var monster_health_text
var monster_actions
var monster_init

var picross_container
var cur_card
var player_hand_container

#var playerDeckDef
var playerDeck

signal player_attack
signal battle_ended

func init(playerDeckDef, playerHealth, encounter):
	player_health = playerHealth
	
	sprite_container = $PanelContainer/MarginContainer/GridContainer/SpriteContainer
	monster_health_text = $PanelContainer/MarginContainer/GridContainer/MonsterName/MonsterHealth
	player_health_text = $PlayerSide/PlayerMargins/PlayerLayout/PlayerHealth
	monster_actions = $PanelContainer/MarginContainer/GridContainer/MonsterActions
	picross_container = $PlayerSide/PlayerMargins/PlayerLayout/PicrossContainer
	player_hand_container = $PlayerSide/PlayerMargins/PlayerLayout/PlayerHandContainer
	current_monster = monster_scene.instance()
	
	sprite_container.add_child(current_monster)
	var sprite_rect = sprite_container.get_rect()
	current_monster.position.x = sprite_container.rect_position.x + sprite_rect.size.x / 2
	current_monster.position.y = sprite_container.rect_position.y + sprite_rect.size.y / 2
	self.connect("player_attack", current_monster, "take_damage")
	current_monster.connect("monster_attack", self, "player_take_damage")
	current_monster.connect("monster_queue_change", self, "update_monster_queue")
	current_monster.connect("monster_death", self, "_onMonsterDeath")
	current_monster.init(encounter)
	
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

func _tryDrawCard():
	if player_hand_container.cardCount() < 5:
		player_hand_container.addCard(playerDeck.draw(), self)


func _process(delta):
	monster_health_text.text = str(current_monster.remaining_health)
	player_health_text.text = str(player_health)
	pass

func player_take_damage(damage):
	player_health -= damage
	
	if player_health <= 0:
		emit_signal("battle_ended", player_health)
	pass

func _onMonsterDeath():
	current_monster.disconnect("monster_death", self, "_onMonsterDeath")
	emit_signal("battle_ended", player_health)
	pass

func update_monster_queue(action_queue):
	for n in monster_actions.get_children(): 
		monster_actions.remove_child(n)
		n.queue_free()

	for x in action_queue:
		var label = Label.new()
		label.align = Label.ALIGN_CENTER
		label.align = Label.VALIGN_BOTTOM
		match(x):
			action_type.ACTION_IDLE:
				label.text = "Idle"
			action_type.ACTION_ATTACK:
				label.text = "Attack"
			action_type.ACTION_CHANGE_WEAKNESS:
				label.text = "Change Defense"
			action_type.ACTION_CHANGE_ATTACK:
				label.text = "Change Attack"
			action_type.ACTION_POWERUP:
				label.text = "Power Up"
		monster_actions.add_child(label)
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

func _on_picross_complete():
	if cur_card.getCardDef() is AttackCardDef:
		emit_signal("player_attack", cur_card.getCardDef().attackType,  cur_card.getCardDef().damage)
	picross_container.remove_child( cur_card.getPuzzle())
	cur_card.getPuzzle().disconnect("complete_puzzle", self, "_on_picross_complete")
	player_hand_container.removeCard(cur_card, self);
	playerDeck.discard(cur_card.getCardDef())
	cur_card = null
	
	pass

