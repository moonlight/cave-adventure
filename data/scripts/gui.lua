-- gui.lua
-- Basic GUI drawing functions
-- By Bj�rn Lindeijer

GUI = {}

function GUI:init()
	self.bitmap   = m_get_bitmap("gui_green.bmp")

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

	self.borderWidth = 2
end

function GUI:_drawBox(bg, ul, ur, ll, lr, bu, bl, br, bd, x, y, w, h)
	m_set_cursor(x, y)
	draw_icon(ul)
	draw_rect(bu, w - (self.borderWidth * 2), self.borderWidth)
	draw_icon(ur)

	m_set_cursor(x, y + self.borderWidth)
	draw_rect(bl, self.borderWidth,           h - (self.borderWidth * 2))
	draw_rect(bg, w - (self.borderWidth * 2), h - (self.borderWidth * 2))
	draw_rect(br, self.borderWidth,           h - (self.borderWidth * 2))

	m_set_cursor(x, y + h - self.borderWidth)
	draw_icon(ll)
	draw_rect(bd, w - (self.borderWidth * 2), self.borderWidth)
	draw_icon(lr)
end

function GUI:drawBox(x, y, w, h)
	-- Shadow
	m_set_alpha(64)
	self:_drawBox(
		self.shadow,
		self.shadowUL, self.shadowUR,
		self.shadowLL, self.shadowLR,
		self.shadow, self.shadow,
		self.shadow, self.shadow,
		x+2, y+2, w, h
	)

	-- The actual box
	m_set_alpha(128)
	self:_drawBox(
		self.bg,
		self.cornerUL, self.cornerUR,
		self.cornerLL, self.cornerLR,
		self.borderU,  self.borderL,
		self.borderR,  self.borderD,
		x, y, w, h
	)

	m_set_alpha(255)
end
