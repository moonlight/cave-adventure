-- Turtle

Turtle = Enemy:subclass
{
	name = "Turtle";
	bPlaceable = true;

	defaultproperties = {
		attackMinDam = 1,
		attackMaxDam = 4,
		maxHealth = 50,
		speed = 1,
		experience = 20,

		offset_y = 4,
		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("turtle.bmp"), 26, 14),
		deathBitmap = m_get_bitmap("turtle_dead.bmp"),
		nature = AGGRESSIVE,
		controllerClass = AdvAIRandom,
		
		hitEffectHeight = 0,
	};
}
