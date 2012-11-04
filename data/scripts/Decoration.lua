--
-- A subclass for decorations. Decorations can be animated and usually have
-- some remarks attached to it.
--
-- By Bjorn Lindeijer

import("Actor.lua")


Decoration = Actor:subclass
{
	name = "Decoration";

	init = function(self)
		if (self.animType and self.animSeq) then
			self:loopAnim(self.animType:new(self.animSeq), self.animSpeed)
			self.tick_time = 1
		end

		if (self.convTable or self.convTableKeyword) then
			self.bCanActivate = true
		end

		Actor.init(self)
	end;

	activatedBy = function(self, instigator)
		if (self.convTableKeyword) then
			self.convTable = lang:getConv(self.convTableKeyword)
		end
		
		self:log("activatedBy(" .. instigator:toString() .. ")");
		if (self.convTable) then
			self:log("Showing conversation...");
			n = get_new_n(self.prev_random, #self.convTable)
			self.prev_random = n
			write_conversation(self.convTable[n])

			-- No additional activations
			return true
		end
	end;

	defaultproperties = {
		animSeq = nil,
		tick_time = 0,

		convTable = nil,
		prev_random = -1,
		bCenterBitmap = true,
		bCenterOnTile = true,

		obstacle = 1,
	}
}
