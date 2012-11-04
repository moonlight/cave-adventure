--
-- Controls the behaviour of an enemy Pawn
-- By Bjorn Lindeijer

import("Controller.lua")


AIController = Controller:subclass
{
	name = "AIController";

	tick = function(self)
		if (self.pawn.charging > 0) then self.pawn.charging = self.pawn.charging - 1 end

		if (self.target and (self.target.map ~= self.pawn.map or self.target.bDead)) then
			-- Abort target
			self.target = nil
		end

		-- When my pawn is ready, it's waiting for something to happen to take action
		if (self.pawn.bAttacking == false and self.target) then
			-- Check if target is drawing near
			local targetDist = self.pawn:distanceTo(self.target)
			local targetDir  = self.pawn:directionTo(self.target)

			if (targetDist < 5) then
				-- Chase or attack?
				if (targetDist == 1) then
					-- Attack on charged
					if (self.pawn.charging == 0 and self.pawn.walking == 0) then
						self.pawn.dir = targetDir
						self.pawn:attack()
					end
				else
					-- TODO: Enhance walking to target algorithm
					if (self.pawn.walking == 0) then
						self.pawn:walk(targetDir)
					end
				end
			elseif (targetDist > 15) then
				-- Abort target
				self.target = nil
			end
		end
	end;

	notifyHearNoise = function(self, loudness, noiseMaker)
		if (noiseMaker:instanceOf(Player) and (not self.target or self.pawn:distanceTo(self.target) > self.pawn:distanceTo(noiseMaker))) then
			self.target = noiseMaker
		end
	end;

	notifyTakeDamage = function(self, damage, instigator, damageType, momentum, location)
		if (instigator) then
			self.target = instigator
		end
	end;
}
