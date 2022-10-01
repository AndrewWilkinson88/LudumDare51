extends CardDef

class_name AttackCardDef

enum ATTACK_TYPE { FIRE,AIR, ICE, PHYSICAL}

export(int) var damage = 10
export(ATTACK_TYPE) var attackType = ATTACK_TYPE.FIRE
export(Array, Texture) var picrossPool
export(Texture) var cardArt

var pickedPicross:Texture

func _init():
	if picrossPool.size() > 0:
		var r = RandomNumberGenerator.new()
		pickedPicross = picrossPool[r.randi_range(0, picrossPool.size()-1)]

func getPuzzle():
	return pickedPicross
