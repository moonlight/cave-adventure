-- vuur.lua
-- The vuur by Frode

Vuur = {}

function Vuur:event_init()
	inherit(self, BasicObject)
	inherit(self, LinearAni)

	self:start_animation{
		m_get_bitmap("vuur_0006.tga"),
		m_get_bitmap("vuur_0011.tga"),
		m_get_bitmap("vuur_0016.tga"),
		m_get_bitmap("vuur_0021.tga"),
		m_get_bitmap("vuur_0026.tga"),
		m_get_bitmap("vuur_0031.tga"),
		m_get_bitmap("vuur_0036.tga"),
		m_get_bitmap("vuur_0041.tga"),
		m_get_bitmap("vuur_0046.tga"),
		m_get_bitmap("vuur_0051.tga"),
		m_get_bitmap("vuur_0056.tga"),
		m_get_bitmap("vuur_0061.tga"),
		m_get_bitmap("vuur_0066.tga"),
		m_get_bitmap("vuur_0071.tga"),
		m_get_bitmap("vuur_0076.tga"),
		m_get_bitmap("vuur_0081.tga"),
		m_get_bitmap("vuur_0086.tga"),
		m_get_bitmap("vuur_0091.tga"),
		m_get_bitmap("vuur_0096.tga"),
	}
	self.tick_time = 10
	self.draw_mode = DM_ALPHA
end

function Vuur:event_activate(instigator)
	local text_table = {
		conv.FIRE_1,
		conv.FIRE_2,
		conv.FIRE_3,
		conv.FIRE_4,
	}

	repeat n = math.random(table.getn(text_table)) until (n ~= self.prev_random)
	self.prev_random = n

	write_conversation(text_table[n])
end