-- An controller which makes its Pawn walk around randomly
--
-- By Bjorn Lindeijer

import("Controller.lua")

AIRandom = Controller:subclass
{
	name = "AIRandom";

	init = function(self)
		self.waitTime = math.random(100) + 10
	end;

	notifyBumpInto = function(self, obj)
		-- Pause for some time and choose another direction
		self.waitTime = math.random(100) + 10
	end;

	notifyWalkFinished = function(self)
		if (self.distanceToWalk <= 0) then
			-- Reached his goal, pause and choose new goal.
			self.waitTime = math.random(100) + 10
		else
		    -- Walking to goal, keep walking.
		    self.distanceToWalk = self.distanceToWalk - 1
		    self.pawn:walk(self.pawn.dir)
		end
	end;

	tick = function(self)
		if (self.waitTime > 0) then
			self.waitTime = self.waitTime - 1

			if (self.waitTime <= 0) then
				-- Choose new goal and start walking towards it
				self.distanceToWalk = math.random(4)
				self.pawn.dir = math.random(4) - 1
				self.pawn:walk(self.pawn.dir)
			end
		end
	end;

	defaultproperties = {
		distanceToWalk = 0,
	};
}
