-- static_objects.lua
-- Here we define some static objects.
-- By Frode Lindeijer



Hakblok = {}
function Hakblok:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_ALPHA
	self.bitmap = m_get_bitmap("hakblok.tga")
	self.offset_y = -6
	self.w = 1
	self.h = 1
end

Roltafel = {}
function Roltafel:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_ALPHA
	self.bitmap = m_get_bitmap("roltafel.tga")
	self.offset_x = 24
	self.offset_y = 12
	self.w = 3
	self.h = 1
end

Bank = {}
function Bank:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_ALPHA
	self.bitmap = m_get_bitmap("bank.tga")
	self.offset_y = 8
	self.w = 1
	self.h = 1
end

-- It's a haag. 'Haag' is the Dutch word for hage.
Haag = {}

function Haag:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("haag.bmp")
	self.offset_x = 12
	self.w = 2
	self.h = 1
end

Haag2 = {}

function Haag2:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("haag2.bmp")
	self.offset_x = 12
	self.w = 2
	self.h = 1
end

Haag3 = {}

function Haag3:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("haag3.bmp")
	self.offset_x = 12
	self.w = 2
	self.h = 1
end