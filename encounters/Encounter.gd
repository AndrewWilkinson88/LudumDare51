extends Resource

class_name Encounter

enum WEAKNESS_TYPE {WEAKNESS_FIRE, WEAKNESS_AIR, WEAKNESS_WATER, WEAKNESS_LIGHT}

export(String) var encounterName
export(int) var health
export(int) var attack
#Levels this enemy can appear on
export(Array,int) var levels
export(Texture) var enemy
export(Array,WEAKNESS_TYPE) var allowed_weaknesses
