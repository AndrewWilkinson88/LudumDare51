extends Sprite
signal monster_attack
signal monster_spawn
signal monster_queue_change

signal monster_death

enum action_type {ACTION_ATTACK, ACTION_IDLE, ACTION_POWERUP, ACTION_CHANGE_ATTACK, ACTION_CHANGE_WEAKNESS}
enum attack_type {ATTACK_FIRE, ATTACK_AIR, ATTACK_WATER, ATTACK_PHYSICAL}
enum weakness_type {WEAKNESS_FIRE, WEAKNESS_WATER, WEAKNESS_ICE, WEAKNESS_LIGHT}

var action_queue = []

var remaining_health
var current_action
var action_counter
var current_attack_type
var current_attack_damage
var current_weakness_type

var monsterName:String
var weaknessPool:Array
var enemy_sprite;

func init(encounterDef:Encounter):
	
	action_counter = 0
	
	monsterName = encounterDef.encounterName
	remaining_health = encounterDef.health
	current_attack_damage = encounterDef.attack
	weaknessPool = []
	for weakness in encounterDef.allowed_weaknesses:
		weaknessPool.append(weakness)
	texture = encounterDef.enemy
	current_action = action_type.ACTION_IDLE
	current_attack_type = attack_type.ATTACK_PHYSICAL
	current_weakness_type = weaknessPool[randi() % weaknessPool.size()]
	
	$MonsterActionTimer.start()
	action_queue.push_back(action_type.ACTION_IDLE)
	action_queue.push_back(action_type.ACTION_ATTACK)
	action_queue.push_back(action_type.ACTION_CHANGE_ATTACK)
	action_queue.push_back(action_type.ACTION_IDLE)
	action_queue.push_back(action_type.ACTION_ATTACK)
	action_queue.push_back(action_type.ACTION_POWERUP)
	emit_signal("monster_queue_change", action_queue)
	
func _process(delta):
	$ProgressBar.value = 10 - $MonsterActionTimer.time_left
	pass
	
func add_next_action(next_action):
	if( action_counter % 6 == 0 ):
		action_queue.push_back(action_type.ACTION_POWERUP)
		pass
	action_queue.push_back(next_action)
	emit_signal("monster_queue_change", action_queue)
	pass

func take_damage(type, amount):
	if( type == current_weakness_type):
		remaining_health -= (amount * 2)
	else:
		remaining_health -= amount
		
	if remaining_health <= 0:
		emit_signal("monster_death")
	pass

func take_monster_action():
	action_counter += 1
	current_action = action_queue.pop_front()
	match( current_action ):
		action_type.ACTION_IDLE:
			var next = randi() % 4
			if( next <= 2 ):
				add_next_action(action_type.ACTION_ATTACK)
			elif( next == 3):
				add_next_action(action_type.ACTION_CHANGE_WEAKNESS)
			pass
		action_type.ACTION_ATTACK:
			var next = randi() % 4
			if( next <= 2 ):
				add_next_action(action_type.ACTION_IDLE)
			elif( next == 3):
				add_next_action(action_type.ACTION_CHANGE_ATTACK)
			emit_signal("monster_attack", current_attack_damage)
			pass
		action_type.ACTION_CHANGE_WEAKNESS:
			var next = randi() % 2
			if( next == 0 ):
				add_next_action(action_type.ACTION_IDLE)
			elif( next == 1):
				add_next_action(action_type.ACTION_CHANGE_ATTACK)
			pass
		action_type.ACTION_CHANGE_ATTACK:
			var next = randi() % 2
			if( next == 0 ):
				add_next_action(action_type.ACTION_IDLE)
			elif( next == 1):
				add_next_action(action_type.ACTION_ATTACK)
			pass
		action_type.ACTION_POWERUP:
			current_attack_damage += 5
			pass
	pass # Replace with function body.
