-- 
-- A rat.
-- 
-- bodged by Hedde Bosman

import("Player.lua")
import("AdvAIRandom.lua")
import("Shadow.lua")


RatShadow = Shadow:subclass
{
	name = "RatShadow";

	defaultproperties = {
		offset_z = -3,
		bitmap = m_get_bitmap("rat_s.tga"),
	};
}

Rat = Enemy:subclass
{
	name = "Rat";
	bPlaceable = true;
	
	defaultproperties = {
		attackMinDam = 0,
		attackMaxDam = 2,
		maxHealth = 20,
		speed = 4,
		experience = 12,

		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("rat.bmp"), 16, 16),
		deathBitmap = m_get_bitmap("rat_dead.bmp"),
		nature = NEUTRAL,
		controllerClass = AdvAIRandom,
		shadowClass = RatShadow,
		
		hitEffectHeight = 0,
	};
}
