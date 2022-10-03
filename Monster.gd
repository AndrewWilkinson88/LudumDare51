extends Sprite

class_name Monster 

signal monster_attack
signal monster_spawn
signal monster_queue_change
signal monster_attack_change

signal monster_death

enum action_type {ACTION_ATTACK, ACTION_IDLE, ACTION_POWERUP, ACTION_CHANGE_WEAKNESS}
enum weakness_type {FIRE, AIR, WATER, LIGHT}

var action_queue = []

var remaining_health
var current_action
var action_counter
var current_attack_damage
var current_weakness_type

var monsterName:String
var weaknessPool:Array
var enemy_sprite;

func init(encounterDef:Encounter):
	randomize()
	action_counter = 0
	
	monsterName = encounterDef.encounterName
	remaining_health = encounterDef.health
	current_attack_damage = encounterDef.attack
	weaknessPool = []
	for weakness in encounterDef.allowed_weaknesses:
		weaknessPool.append(weakness)
	texture = encounterDef.enemy
	current_action = action_type.ACTION_IDLE
	current_weakness_type = weaknessPool[randi() % weaknessPool.size()]
	
	$MonsterActionTimer.start()
	action_queue.push_back(action_type.ACTION_IDLE)
	action_queue.push_back(action_type.ACTION_ATTACK)
	action_queue.push_back(action_type.ACTION_CHANGE_WEAKNESS)
	action_queue.push_back(action_type.ACTION_IDLE)
	emit_signal("monster_queue_change", action_queue)
	
func add_next_action(next_action):
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
	var next_action
	match( current_action ):
		action_type.ACTION_IDLE:
			pass
		action_type.ACTION_ATTACK:
			emit_signal("monster_attack", current_attack_damage)
			pass
		action_type.ACTION_CHANGE_WEAKNESS:
			pass
		action_type.ACTION_POWERUP:
			current_attack_damage += 5
			emit_signal("monster_attack_change", current_attack_damage)
			pass
			
	if( action_counter % 4 == 0 ):
		next_action = action_type.ACTION_POWERUP
		pass
	else:
		var next = randi() % 3
		match(next):
			0: 
				next_action = action_type.ACTION_IDLE
			1: 
				next_action = action_type.ACTION_ATTACK
			2: 
				next_action = action_type.ACTION_CHANGE_WEAKNESS
		pass
	
	add_next_action(next_action)
	pass # Replace with function body.
