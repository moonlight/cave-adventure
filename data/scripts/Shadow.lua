--
-- A shadow following his caster
-- By Bjorn Lindeijer

import("Actor.lua")

Shadow = Actor:subclass
{
	name = "Shadow";

	preRender = function(self)
		if (self.owner) then
			-- Keep along with my owner
			self.x = self.owner.x
			self.y = self.owner.y
			--self.offset_x = self.owner.offset_x
			--self.offset_y = self.owner.offset_y
			self.alpha = self.owner.alpha

			if (self.myMap ~= self.owner.myMap) then
				self:setMap(self.owner.myMap)
			end
		end
	end;

	defaultproperties = {
		offset_z = -1,
		draw_mode = DM_ALPHA,
		bitmap = m_get_bitmap("blobshadow.tga"),
		bCenterBitmap = true,
	};
}
