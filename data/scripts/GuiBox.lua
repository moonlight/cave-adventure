--
-- A box used for use around message windows and menus
-- By Bjorn Lindeijer

import("Object.lua")


GuiBox = Object:subclass
{
	name = "GuiBox";

	init = function(x, y, w, h)
		self.x = x or 0
		self.y = y or 0
		self.w = w or 0
		self.h = h or 0
	end;

	draw = function()

	end;
}