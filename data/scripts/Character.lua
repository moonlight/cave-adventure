-- Character.lua
-- A base class for anything that walks like a character
-- By Bjørn Lindeijer

import("Actor.lua")


Character = Actor:subclass
{
	defaultproperties = {
		speed = 3,
		offset_y = -6,
		draw_mode = DM_ALPHA,
		obstacle = 1,
	}
}