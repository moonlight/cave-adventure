-- By Bjorn Lindeijer


import("Interaction.lua")

GuiMenu = Interaction:subclass
{
	name = "GuiMenu";

	init = function(self)
		self.menuItems = {}
	end;

	addMenuItem = function(self, menuItem)
		if (not menuItem) then
			m_message("Warning: addMenuItem called without a menu item!")
			return
		end

		table.insert(self.menuItems, menuItem)
		menuItem.menu = self

		-- Adjust menu size
		self.h = self.h + menuItem:getHeight() + 1
		self.w = math.max(self.w, menuItem:getWidth())
	end;

	postRender = function(self, canvas)
		if (self.bCenter) then
			local sw, sh = m_screen_size()
			self.x = (sw - self.w) / 2
			self.y = (sh - self.h) / 2
		end

		m_set_font(guiTheme.font)
		canvas:setDrawMode(DM_TRANS)

		local curr = 0
		for i = 1, table.getn(self.menuItems) do
			local tw, th = m_text_size(self.menuItems[i].text)
			m_set_color(0, 0, 0)
			m_set_cursor(self.x + (self.w - tw) / 2 + 1, self.y + curr + 1 + 1)
			m_draw_text(self.menuItems[i].text)
			curr = curr + self.menuItems[i]:getHeight() + 1
		end

		guiTheme:drawBox(self.x - 2, self.y - 2, self.w + 4, self.h + 3)

		local curr = 0
		for i = 1, table.getn(self.menuItems) do
			if (i == self.selected) then
				guiTheme:drawBox(self.x, self.y + curr, self.w, self.menuItems[i]:getHeight())
				m_set_color(200, 200, 200)
			else
				m_set_color(175, 175, 175)
			end

			local tw, th = m_text_size(self.menuItems[i].text)
			m_set_cursor(self.x + (self.w - tw) / 2, self.y + curr + 1)
			m_draw_text(self.menuItems[i].text)
			curr = curr + self.menuItems[i]:getHeight() + 1
		end
	end;

	keyType = function(self, key)
		if (key == "up") then
			self.selected = self.selected - 1
			if (self.selected == 0) then self.selected = table.getn(self.menuItems) end
			m_play_sample("bbsfx_hit1.wav")
			return true
		elseif (key == "down") then
			self.selected = self.selected + 1
			if (self.selected > table.getn(self.menuItems)) then self.selected = 1 end
			m_play_sample("bbsfx_hit1.wav")
			return true
		elseif (key == "action") then
			self.menuItems[self.selected].func()
			m_play_sample("bbsfx_hit1.wav")
			return true
		end
	end;

	setInteractionMaster = function(self, master)
		if (self.master and not master) then
			ActionController:addAction(ActionExModeOff())
		elseif (not self.master and master) then
			ActionController:addAction(ActionExModeOn())
		end

		Interaction.setInteractionMaster(self, master)
	end;

	defaultproperties = {
		menuItems = nil,
		h = 0,
		w = 0,
		x = 0,
		y = 0,
		bCenter = true,
		selected = 1,
	}
}