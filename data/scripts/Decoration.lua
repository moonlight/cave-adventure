-- Decoration.lua
-- A subclass for decorations. Decorations can be animated and usually have
-- some remarks attached to it.
-- By Bjørn Lindeijer

import("Actor.lua")
import("Animation.lua")


Decoration = Actor:subclass
{
	init = function(self)
		if (self.animType) then
			self.animInst = self.animType:new()
			self.animInst:start(self.animSeq)
		end
	end;

	event_activate = function(self, instigator)
		if (self.convTable) then
			n = get_new_n(self.prev_random, table.getn(self.convTable))
			self.prev_random = n
			write_conversation(self.convTable[n])
		end
	end;

	event_tick = function(self)
		if (self.animInst) then
			self.animInst:update()
			self.bitmap = self.animInst.bitmap
		end
	end;

	defaultproperties = {
		animType = nil,
		animSeq = nil,
		animInst = nil,

		convTable = nil,
		prev_random = -1,

		obstacle = 1,
	}
}
