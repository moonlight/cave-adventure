--
-- The spring by Frode
--

import("Decoration.lua")
import("Animation.lua")
import("lang.lua")


Spring = Decoration:subclass
{
	name = "Spring";

	activatedBy = function(self, instigator)
		Decoration.activatedBy(self, instigator)

		if (instigator.health < instigator.maxHealth) then
			ActionController:addSequence({
				ActionTweenVariable(instigator, "health", 2*(instigator.maxHealth - instigator.health), instigator.maxHealth),
			})
		end
	end;

	defaultproperties = {
		animType = LinearAnimation,
		animSeq = extr_array(m_get_bitmap("spring.bmp"), 48, 72),
		animSpeed = 1 / 8,
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
