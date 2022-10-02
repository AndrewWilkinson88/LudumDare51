extends CardDef

class_name AttackCardDef

enum ATTACK_TYPE { FIRE,AIR, WATER, LIGHT}

export(int) var damage = 10
export(ATTACK_TYPE) var attackType = ATTACK_TYPE.FIRE
