-- Decoration.lua
-- A subclass for decorations. Decorations can be animated and usually have
-- some remarks attached to it.
-- By Bjørn Lindeijer

import("Actor.lua")


Decoration = Actor:subclass
{
	name = "Decoration";

	init = function(self)
		if (self.animType and self.animSeq) then
			self:loopAnim(self.animType:new(self.animSeq), self.animSpeed)
		end

		if (self.convTable) then
			self.bCanActivate = true
		end
	end;

	activatedBy = function(self, instigator)
		if (self.convTable) then
			n = get_new_n(self.prev_random, table.getn(self.convTable))
			self.prev_random = n
			write_conversation(self.convTable[n])
		end
	end;

	--[[
	tick = function(self)
		if (self.animInst) then
			self.animInst:update()
			self.bitmap = self.animInst.bitmap
		end
	end;
	]]

	defaultproperties = {
		animSeq = nil,
		tick_time = 1,

		convTable = nil,
		bCanActivate = false,
		prev_random = -1,

		obstacle = 1,
	}
}
