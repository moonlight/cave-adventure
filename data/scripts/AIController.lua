--
-- Controls the behaviour of a Pawn
-- By Bjørn Lindeijer

import("Controller.lua")


AIController = Controller:subclass
{
	name = "AIController";

	tick = function(self)
		if (self.pawn.charge > 0) then self.pawn.charge = self.pawn.charge - 1 end

		-- Switch to ready from walking
		if (self.pawn.state == AI_WALKING and self.pawn.walking == 0) then
			self.pawn:setState(AI_READY)
		end

		-- When an AI is ready, it's waiting for something to happen to take action
		if (self.pawn.state == AI_READY) then
			-- Check if player is drawing near
			local playerDist = playerDistance(self.pawn)
			local player = m_get_player()

			if (playerDist < 5 and player.state ~= CHR_DEAD) then
				-- Chase or attack?
				if (playerDist <= self.pawn.attack_range) then
					-- Attack on charged
					if (self.pawn.charge == 0 and self.pawn.walking == 0) then
						self.pawn.dir = playerDirection(self.pawn)
						self.pawn:attack()
					end
				else
					self.pawn:walk(playerDirection(self.pawn))
				end
			end
		end
	end;
}
