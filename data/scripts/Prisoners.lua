-- The evil prisoners, moehaha
-- By Georg Muntingh

import("Player.lua")

Prisoner1 = Character:subclass
{
	name = "Prisoner1";
	bPlaceable = true;

	defaultproperties = {
		speed = 2,
		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("prisoner1.bmp"), 24, 34),
		controllerClass = AIRandom,
	};
}

Prisoner2 = Character:subclass
{
	name = "Prisoner2";
	bPlaceable = true;

	defaultproperties = {
		speed = 2,
		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("prisoner2.bmp"), 23, 40),
		controllerClass = AIRandom,
	};
}

Prisoner3 = Character:subclass
{
	name = "Prisoner3";
	bPlaceable = true;

	defaultproperties = {
		speed = 2,
		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("prisoner3.bmp"), 24, 34),
		controllerClass = AIRandom,
	};
}
