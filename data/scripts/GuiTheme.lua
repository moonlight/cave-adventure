--
-- The GUI theme
-- By Bjorn Lindeijer

import("Object.lua")


GuiTheme = Object:subclass
{
	name = "GuiTheme";

	init = function(self)
		self.cornerUL = m_create_sub_bitmap(self.bitmap, 1, 0, 2, 2)
		self.cornerUR = m_create_sub_bitmap(self.bitmap, 3, 0, 2, 2)
		self.cornerLL = m_create_sub_bitmap(self.bitmap, 1, 2, 2, 2)
		self.cornerLR = m_create_sub_bitmap(self.bitmap, 3, 2, 2, 2)

		self.borderU  = m_create_sub_bitmap(self.bitmap, 9,  0, 2, 2)
		self.borderL  = m_create_sub_bitmap(self.bitmap, 11, 0, 2, 2)
		self.borderR  = m_create_sub_bitmap(self.bitmap, 11, 2, 2, 2)
		self.borderD  = m_create_sub_bitmap(self.bitmap, 9,  2, 2, 2)

		self.bg       = m_create_sub_bitmap(self.bitmap, 0, 0, 1, 1)
		self.shadow   = m_create_sub_bitmap(self.bitmap, 0, 1, 1, 1)

		self.shadowUL = m_create_sub_bitmap(self.bitmap, 5, 0, 2, 2)
		self.shadowUR = m_create_sub_bitmap(self.bitmap, 7, 0, 2, 2)
		self.shadowLL = m_create_sub_bitmap(self.bitmap, 5, 2, 2, 2)
		self.shadowLR = m_create_sub_bitmap(self.bitmap, 7, 2, 2, 2)

		self.canvas   = Canvas()
	end;

	drawBox = function(self, x, y, w, h)
		self.canvas:setDrawMode(DM_TRANS)

		-- Shadow
		local alpha = m_set_alpha(64)
		self:drawBoxEx(
			self.shadow,
			self.shadowUL, self.shadowUR, self.shadowLL, self.shadowLR,
			self.shadow,   self.shadow,   self.shadow,   self.shadow,
			x+2, y+2, w, h
		)

		-- The actual box
		m_set_alpha(128)
		self:drawBoxEx(
			self.bg,
			self.cornerUL, self.cornerUR, self.cornerLL, self.cornerLR,
			self.borderU,  self.borderL,  self.borderR,  self.borderD,
			x, y, w, h
		)

		m_set_alpha(alpha)
	end;
	
	drawLightBox = function(self, x, y, w, h)
		self.canvas:setDrawMode(DM_TRANS)

		local alpha = m_set_alpha(128)
		self:drawBoxEx(
			self.bg,
			self.cornerUL, self.cornerUR, self.cornerLL, self.cornerLR,
			self.borderU,  self.borderL,  self.borderR,  self.borderD,
			x, y, w, h
		)
		m_set_alpha(alpha)
	end;
	
	getTextColor = function(self)
		return 170, 170, 170
	end;

	drawBoxEx = function(self, bg, ul, ur, ll, lr, bu, bl, br, bd, x, y, w, h)
		m_set_cursor(x, y)
		self.canvas:drawIcon(ul)
		self.canvas:drawRect(bu, w - (self.borderWidth * 2), self.borderWidth)
		self.canvas:drawIcon(ur)

		m_set_cursor(x, y + self.borderWidth)
		self.canvas:drawRect(bl, self.borderWidth,           h - (self.borderWidth * 2))
		self.canvas:drawRect(bg, w - (self.borderWidth * 2), h - (self.borderWidth * 2))
		self.canvas:drawRect(br, self.borderWidth,           h - (self.borderWidth * 2))

		m_set_cursor(x, y + h - self.borderWidth)
		self.canvas:drawIcon(ll)
		self.canvas:drawRect(bd, w - (self.borderWidth * 2), self.borderWidth)
		self.canvas:drawIcon(lr)
	end;


	defaultproperties =
	{
		bitmap = m_get_bitmap("gui_green.bmp"),
		font = "font_sansserif8.pcx",
		borderWidth = 2,
		canvas = nil,
	};
}
