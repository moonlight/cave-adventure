--
-- A character is a pawn with a specific animation scheme
-- By Bjørn Lindeijer

import("Pawn.lua")


Character = Pawn:subclass
{
	name = "Character";

	init = function(self, char)
		Pawn.init(self)
		self:updateBitmap()
	end;

	updateBitmap = function(self)
		local ani = self.charAnim
		if (ani) then
			if (self.attacking == 1) then
				self.bitmap = ani[self.dir + 1 + 3 * 4]
			else
				if (self.walking == 0 or self.walking < 50) then
					self.bitmap = ani[self.dir + 1]
				else
					self.bitmap = ani[self.dir + 1 + (self.leg_used + 1) * 4]
				end
			end
		end
	end;

	event_walk_start = function(self)
		self.leg_used = 1 - self.leg_used
	end;

	event_walk_finished = function(self)
		self:updateBitmap()
	end;

	event_dir_change = function(self)
		self:updateBitmap()
	end;

	tick = function(self)
		Pawn.tick(self)
		self:updateBitmap()
	end;


	defaultproperties = {
		leg_used = 0,
		tick_time = 1,
		walking = 0,
		charAnim = nil,
	};
}

