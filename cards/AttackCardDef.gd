extends CardDef

class_name AttackCardDef

enum ATTACK_TYPE { FIRE,AIR, ICE, PHYSICAL}

export(int) var damage = 10
export(ATTACK_TYPE) var attackType = ATTACK_TYPE.FIRE
