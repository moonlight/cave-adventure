--
-- The base class for any GUI widget.
-- By Bjorn Lindeijer

import("Object.lua")

GuiWidget = Object:subclass
{
	name = "GuiWidget";

	-- Querying the size of the widget
	getHeight = function(self)
		return 0
	end;

	getWidth = function(self)
		return 0
	end;

	getSize = function(self)
		return self:getWidth(), self:getHeight()
	end;
}