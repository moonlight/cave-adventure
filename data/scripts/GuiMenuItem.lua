
import("GuiWidget.lua")

GuiMenuItem = GuiWidget:subclass
{
	name = "GuiMenuItem";

	init = function(self, text, func)
		self.text = text
		self.func = func

		m_set_font(guiTheme.font)
		self.w, self.h = m_text_size(self.text)
		self.w = self.w + 4
		self.h = self.h + 2
	end;

	setText = function(self, text)
		self.text = text
		m_set_font(guiTheme.font)
		self.w, self.h = m_text_size(self.text)
		self.w = self.w + 4
		self.h = self.h + 2

		if (self.menu) then
			-- Somehow adapt the size of the menu
		end
	end;

	getWidth = function(self)
		return self.w
	end;

	getHeight = function(self)
		return self.h
	end;

	defaultproperties = {
		text = "",
		func = nil,
		w = 0,
		h = 0,
		menu = nil,
	}
}