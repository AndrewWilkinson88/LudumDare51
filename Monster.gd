extends Sprite
signal monster_attack
signal monster_spawn
signal monster_queue_change

enum action_type {ACTION_ATTACK, ACTION_IDLE, ACTION_POWERUP, ACTION_CHANGE_WEAKNESS}
enum weakness_type {WEAKNESS_FIRE, WEAKNESS_AIR, WEAKNESS_ICE, WEAKNESS_LIGHT}

var action_queue = []

var remaining_health
var current_action
var action_counter
var current_attack_damage
var current_weakness_type

# Called when the node enters the scene tree for the first time.
func _ready():
	remaining_health = 100
	current_attack_damage = 5
	action_counter = 0
	current_action = action_type.ACTION_IDLE
	current_weakness_type = weakness_type.WEAKNESS_LIGHT
	randomize()
	pass # Replace with function body.

func init_monster():
	$MonsterActionTimer.start()
	action_queue.push_back(action_type.ACTION_IDLE)
	action_queue.push_back(action_type.ACTION_ATTACK)
	action_queue.push_back(action_type.ACTION_CHANGE_WEAKNESS)
	action_queue.push_back(action_type.ACTION_IDLE)
	emit_signal("monster_queue_change", action_queue)
	pass
	
func add_next_action(next_action):
	action_queue.push_back(next_action)
	emit_signal("monster_queue_change", action_queue)
	pass

func take_damage(type, amount):
	if( type == current_weakness_type):
		remaining_health -= (amount * 2)
	else:
		remaining_health -= amount
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
