-- torch.lua
-- The troch by Frode

Torch = {}

function Torch:event_init()
	inherit(self, BasicObject)
	inherit(self, LinearAni)

	self:start_animation{
		m_get_bitmap("torch1.bmp"),
		m_get_bitmap("torch2.bmp"),
		m_get_bitmap("torch3.bmp"),
		m_get_bitmap("torch4.bmp"),
		m_get_bitmap("torch5.bmp"),
		m_get_bitmap("torch6.bmp"),
	}
	self.tick_time = 10
	self.draw_mode = DM_MASKED
	self.offset_y = -6
end

function Torch:event_activate(instigator)
	local text_table = {
		conv.FIRE_1,
		conv.FIRE_2,
		conv.FIRE_3,
	}

	repeat n = random(getn(text_table)) until (n ~= self.prev_random)
	self.prev_random = n

	write_conversation(text_table[n])
end