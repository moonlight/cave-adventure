--
-- The ingame menu
-- By Bjorn Lindeijer

import("GuiMenu.lua")

IngameMenu = GuiMenu:subclass
{
	name = "IngameMenu";

	init = function(self)
		GuiMenu.init(self)

		self:addMenuItem(GuiMenuItem(lang:getVar("CONTINUE"), function() self.master:removeInteraction(self); end))
		self:addMenuItem(GuiMenuItem(lang:getVar("LANGUAGE"), function()
			self.master:addInteraction(LanguageMenu(self));
			self.master:removeInteraction(self);
		end))
		self:addMenuItem(GuiMenuItem(lang:getVar("QUIT"),     function() self.master:removeInteraction(self); m_quit_game() end))
	end;

	keyType = function(self, key)
		if (GuiMenu.keyType(self, key)) then return true end

		if (key == "esc") then
			self.master:removeInteraction(self)
			return true
		end
	end;

	defaultproperties = {
	}
}
