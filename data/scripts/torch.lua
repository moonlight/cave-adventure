--
-- A torch by Frode
--

import("Decoration.lua")
import("lang.lua")


Torch = Decoration:subclass
{
	name = "Torch";

	defaultproperties = {
		bitmap = m_get_bitmap("torch1.bmp"),
		animType = LinearAni,
		animSeq = {
			m_get_bitmap("torch1.bmp"),
			m_get_bitmap("torch2.bmp"),
			m_get_bitmap("torch3.bmp"),
			m_get_bitmap("torch4.bmp"),
			m_get_bitmap("torch5.bmp"),
			m_get_bitmap("torch6.bmp"),
		},
		convTable = {
			conv.FIRE_1,
			conv.FIRE_2,
			conv.FIRE_3,
		},
		tick_time = 10,
		draw_mode = DM_MASKED,
		offset_y = -6,
	};
}
