-- basic_types.lua
-- Here we define some basic character and object properties, in order to
-- simplify coding characters and objects. A simple form of inheritance is
-- used.
-- By Bjørn Lindeijer

-- Ye most basic object, most objects are obstacles
BasicObject = {
	obstacle = 1,
}

-- Ye most basic character, with a decent walking speed and an offset_y to
-- make characters not stand on the lower edge of a tile but on the middle.
BasicChar = {}
inherit(BasicChar, BasicObject)
inherit(BasicChar, {
	speed = 3,
	offset_y = -6,
	draw_mode = DM_ALPHA,
})

-- A character that can engage in combat. This type is not supported by the
-- engine yet (the engine doesn't use these variables), maybe combat will be a
-- totally scripted thing.
CombatChar = {}
inherit(CombatChar, BasicChar)
inherit(CombatChar, {
	health = 100,
	max_health = 100,
	agi = 5,
	str = 5,
	def = 5,
})