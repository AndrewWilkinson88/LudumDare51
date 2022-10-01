extends Sprite
signal monster_attack
signal monster_spawn
signal monster_queue_change

enum action_type {ACTION_ATTACK, ACTION_IDLE, ACTION_POWERUP, ACTION_CHANGE_ATTACK, ACTION_CHANGE_WEAKNESS}
enum attack_type {ATTACK_FIRE, ATTACK_AIR, ATTACK_ICE, ATTACK_PHYSICAL}
enum weakness_type {WEAKNESS_FIRE, WEAKNESS_AIR, WEAKNESS_ICE, WEAKNESS_LIGHT}

var action_queue = []

var remaining_health
var current_action
var action_counter
var current_attack_type
var current_attack_damage
var current_weakness_type

# Called when the node enters the scene tree for the first time.
func _ready():
	remaining_health = 100
	current_attack_damage = 5
	action_counter = 0
	current_action = action_type.ACTION_IDLE
	current_attack_type = attack_type.ATTACK_PHYSICAL
	current_weakness_type = weakness_type.WEAKNESS_LIGHT
	pass # Replace with function body.

func init_monster():
	$MonsterActionTimer.start()
	action_queue.push_back(action_type.ACTION_IDLE)
	action_queue.push_back(action_type.ACTION_ATTACK)
	action_queue.push_back(action_type.ACTION_CHANGE_ATTACK)
	action_queue.push_back(action_type.ACTION_IDLE)
	action_queue.push_back(action_type.ACTION_ATTACK)
	action_queue.push_back(action_type.ACTION_POWERUP)
	emit_signal("monster_queue_change", action_queue)
	pass
	
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
		remaining_health -= amount
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
