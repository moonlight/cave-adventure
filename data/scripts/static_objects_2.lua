-- static_objects_2.lua
-- Here we define some more static objects.
-- By Bjørn Lindeijer

TuinhekjeHor = {}
function TuinhekjeHor:event_init()
	self.bitmap = m_get_bitmap("tuinhekje_hor.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = -12
end

GaasHekje = {}
function GaasHekje:event_init()
	self.bitmap = m_get_bitmap("gaashekje.bmp")
	self.draw_mode = DM_MASKED
end
OpenHekje = {}
function OpenHekje:event_init()
	self.bitmap = m_get_bitmap("tuinhekje.bmp")
	self.draw_mode = DM_MASKED
	self.offset_y = -21
	self.offset_x = 4
end

GrasPol = {}
function GrasPol:event_init()
	self.bitmap = m_get_bitmap("pol.tga")
	self.draw_mode = DM_ALPHA
	self.offset_y = -4
end

HekBuren = {}
function HekBuren:event_init()
	self.bitmap = m_get_bitmap("hek_buren.bmp")
	self.draw_mode = DM_MASKED
end

