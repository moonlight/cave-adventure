--
-- The spring by Frode
--

import("Decoration.lua")
import("lang.lua")


Spring = Decoration:subclass
{
	name = "Spring";

	event_activate = function(self, instigator)
		Decoration.event_activate(self, instigator)

		if (instigator.health < instigator.maxHealth) then
			ActionController:addSequence({
				ActionTweenVariable(instigator, "health", 2*(instigator.maxHealth - instigator.health), instigator.maxHealth),
			})
		end
	end;

	defaultproperties = {
		animType = LinearAni,
		animSeq = extr_array(m_get_bitmap("spring.bmp"), 48, 72),
		tick_time = 8,
		w = 2,
		h = 1,
		offset_x = 12,
		convTable = {
			conv.REFRESHING,
			conv.COULD_USE_THAT,
			conv.MUCH_BETTER,
		},
		bCanActivate = true,
	};
}
