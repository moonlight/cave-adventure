-- static_objects.lua
-- Here we define some static objects.
-- By Bjørn Lindeijer

Boom = {}
function Boom:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("boom.bmp")
	self.offset_x = -4
end

Boom2 = {}
function Boom2:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("boom2.bmp")
	self.offset_x = -4
end

Boom3 = {}
function Boom3:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("boom3.bmp")
	self.offset_x = -4
end

Boom4 = {}
function Boom4:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("boom4.bmp")
	self.offset_x = 4
end

-- It's a spar. 'Spar' is the Dutch word for pinetree.
Spar1 = {}
function Spar1:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("spar1.bmp")
	self.offset_x = 24
	self.w = 3
	self.h = 2
end

Den = {}
function Den:event_init()
	inherit(self, BasicObject)
	self.bitmap = m_get_bitmap("den.bmp")
	self.draw_mode= DM_MASKED
end

Linde = {}
function Linde:event_init()
	inherit(self, BasicObject)
	self.bitmap = m_get_bitmap("linde.bmp")
	self.draw_mode = DM_MASKED
end

Bielsen_Tafel = {}
function Bielsen_Tafel:event_init()
	inherit(self, BasicObject)

	self.bitmap = m_get_bitmap("bielsen_tafel.bmp")
	self.offset_x = 12
	self.w = 2
	self.h = 2
end

Bokjes_Tafel = {}
function Bokjes_Tafel:event_init()
	inherit(self, BasicObject)

	self.bitmap = m_get_bitmap("bokjes_tafel.bmp")
	self.offset_x = 12
	self.w = 2
end

Vouwwagen = {}
function Vouwwagen:event_init()
	inherit(self, BasicObject)
	self.bitmap = m_get_bitmap("vouwwagen.tga")
	self.draw_mode = DM_ALPHA
	self.offset_x = 7
	self.offset_y = -40
	self.offset_z = -40
end

Kruk = {}
function Kruk:event_init()
	inherit(self, BasicObject)

	self.bitmap = m_get_bitmap("kruk.tga")
	self.draw_mode = DM_ALPHA
	self.offset_y = BasicChar.offset_y - 1
end

Stoel = {}
function Stoel:event_init()
	inherit(self, BasicObject)

	self.bitmap = m_get_bitmap("stoel1.tga")
	self.draw_mode = DM_ALPHA
	self.offset_y = BasicChar.offset_y - 1
end

Plantenbak = {}
function Plantenbak:event_init()
	inherit(self, BasicObject)

	self.bitmap = m_get_bitmap("plantenbak.tga")
	self.draw_mode = DM_ALPHA
	self.offset_x = 60
	self.w = 6
	self.h = 2
end

Afdakje = {}
function Afdakje:event_init()
	self.bitmap = m_get_bitmap("afdakje.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = -10
	self.offset_z = 55
end

Regenpijp = {}
function Regenpijp:event_init()
	self.bitmap = m_get_bitmap("regenpijp.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = 16
	self.offset_z = -26
end

Tomaten_plant1 = {}
function Tomaten_plant1:event_init()
	self.bitmap = m_get_bitmap("tomaten_plant1.bmp")
	self.draw_mode = DM_MASKED
end

Tomaten_plant2 = {}
function Tomaten_plant2:event_init()
	self.bitmap = m_get_bitmap("tomaten_plant2.bmp")
	self.draw_mode = DM_MASKED
end

Krop = {}
function Krop:event_init()
	self.bitmap = m_get_bitmap("krop.bmp")
	self.draw_mode = DM_MASKED
end

Brievenbus = {}
function Brievenbus:event_init()
	self.bitmap = m_get_bitmap("brievenbus.bmp")
	self.draw_mode = DM_MASKED
end

Muur = {}
function Muur:event_init()
	inherit(self, BasicObject)

	self.bitmap = m_get_bitmap("muur.tga")
	self.draw_mode = DM_ALPHA
	self.offset_x = 48
	self.offset_y = -10
end

Barrel = {}
function Barrel:event_init()
	inherit(self, BasicObject)

	self.bitmap = m_get_bitmap("barrel.tga")
	self.draw_mode = DM_ALPHA
	self.offset_x = 0
	self.offset_y = 0
end

--Gewei = {}
--function Gewei:event_init()
--	self.bitmap = m_get_bitmap("gewei.tga")
--	self.draw_mode = DM_ALPHA
--	self.offset_x = 12
--  self.offset_z = -14
--end

Dakondersteuning = {}
function Dakondersteuning:event_init()
	--inherit(self, BasicObject)
	self.bitmap = m_get_bitmap("dakondersteuning.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = -1
	self.offset_z = 1
	self.w = 1
	self.h = 1
end

Hokje = {}
function Hokje:event_init()
	inherit(self, BasicObject)
	self.bitmap = m_get_bitmap("hokje.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = 12
	self.offset_z = 1
	self.w = 2
	self.h = 1
end

Tuinhekje = {}
function Tuinhekje:event_init()
--	inherit(self, BasicObject)
	self.bitmap = m_get_bitmap("tuinhekje2.bmp")
	self.draw_mode = DM_MASKED
--	self.offset_x = 60
--	self.w = 6
--	self.h = 2
end

Prikkeldraad = {}
function Prikkeldraad:event_init()
	self.bitmap = m_get_bitmap("prikkeldraad.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = -12
end

Tentflap = {}
function Tentflap:event_init()
	self.bitmap = m_get_bitmap("tentflap.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = 12
end

Tentflap2 = {}
function Tentflap2:event_init()
	self.bitmap = m_get_bitmap("tentflap2.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = 12
end

Tentstok = {}
function Tentstok:event_init()
	self.bitmap = m_get_bitmap("tentstok.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = 11
end

Zaklamp = {}
function Zaklamp:event_init()
	self.bitmap = m_get_bitmap("zaklamp.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = 11
	self.offset_y = -10
end

Sleepstuff1 = {}
function Sleepstuff1:event_init()
	self.bitmap = m_get_bitmap("sleepstuff1.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = 12
end

Sleepstuff2 = {}
function Sleepstuff2:event_init()
	self.bitmap = m_get_bitmap("sleepstuff2.bmp")
	self.draw_mode = DM_MASKED
	self.offset_x = 12
end

Schuurdak = {}
function Schuurdak:event_init()
	self.bitmap = m_get_bitmap("dak.bmp")
	self.draw_mode = DM_MASKED
	self.offset_z = 67
	self.offset_x = -4
end

Schuurdak2 = {}
function Schuurdak2:event_init()
	self.bitmap = m_get_bitmap("dak2.bmp")
	self.draw_mode = DM_MASKED
end

--
-- All bottle graphics use alpha layer and bottles are generally not
-- obstacles.
--
AlphaNoob = {
	draw_mode = DM_ALPHA,
	obstacle = 0,
}

Bottle1 = {}
function Bottle1:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("bottle1.tga")
end
Bottle2 = {}
function Bottle2:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("bottle2.tga")
end
Bottle3 = {}
function Bottle3:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("bottle3.tga")
end
Bottle4 = {}
function Bottle4:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("bottle4.tga")
end
Bottle5 = {}
function Bottle5:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("bottle5.tga")
end


Stone1 = {}
function Stone1:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("stone1.tga")
end
Stone2 = {}
function Stone2:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("stone2.tga")
end
Stone3 = {}
function Stone3:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("stone3.tga")
end
Stone4 = {}
function Stone4:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("stone4.tga")
end

Krat1 = {}
function Krat1:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("krat1.tga")
end
Krat2 = {}
function Krat2:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("krat2.tga")
end
Krat12 = {}
function Krat12:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("krat12.tga")
end
Krat21 = {}
function Krat21:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("krat21.tga")
end

Chips1 = {}
function Chips1:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("chips1.tga")
end
Chips2 = {}
function Chips2:event_init()
	inherit(self, AlphaNoob)
	self.bitmap = m_get_bitmap("chips2.tga")
end

-- The footsteps.
Feet_u = {}
function Feet_u:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_u.bmp")
end
Feet_r = {}
function Feet_r:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_r.bmp")
end
Feet_d = {}
function Feet_d:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_d.bmp")
end
Feet_l = {}
function Feet_l:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_l.bmp")
end

Feet_rru = {}
function Feet_rru:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_rru.bmp")
end
Feet_ddr = {}
function Feet_ddr:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_ddr.bmp")
end
Feet_lld = {}
function Feet_lld:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_lld.bmp")
end
Feet_uul = {}
function Feet_uul:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_uul.bmp")
end
Feet_drr = {}
function Feet_drr:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_drr.bmp")
end
Feet_ruu = {}
function Feet_ruu:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_ruu.bmp")
end
Feet_ull = {}
function Feet_ull:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_ull.bmp")
end
Feet_ldd = {}
function Feet_ldd:event_init()
	inherit(self, AlphaNoob)
	self.draw_mode = DM_MASKED
	self.offset_y = -20
	self.offset_z = -20
	self.bitmap = m_get_bitmap("feet_ldd.bmp")
end