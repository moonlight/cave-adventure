
import("Character.lua")

Guard = Character:subclass
{
	name = "Guard";

	defaultproperties = {
		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("cop.bmp"), 23, 40),
		dir = DIR_UP,
		speed = 3,
	};
}