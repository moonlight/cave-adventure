--
-- A modification of the general AIController, to take care
-- of the queens ability to give birth.
-- By Bjorn Lindeijer

import("AIController.lua")


QueenController = AIController:subclass
{
	name = "QueenController";

	tick = function(self)
		if (self.pawn.charge > 0) then self.pawn.charge = self.pawn.charge - 1 end
		if (self.pawn.charge_birth > 0) then self.pawn.charge_birth = self.pawn.charge_birth - 1 end

		-- Switch to ready from walking
		if (self.pawn.state == AI_WALKING and self.pawn.walking == 0) then
			self.pawn:setState(AI_READY)
		end

		-- When an AI is ready, it's waiting for something to happen to take action
		if (self.pawn.state == AI_READY) then
			-- Check if player is drawing near
			playerDist = playerDistance(self.pawn)
			--local player = m_get_player()

			if (playerDist < 5 and player.state ~= CHR_DEAD) then
				local space = randomFreeTileAround(self.pawn)

				-- Chase or attack?
				if (playerDist <= self.pawn.attack_range) then
					-- Attack on charged
					if (self.pawn.charge == 0 and self.pawn.walking == 0) then
						self.pawn:attack(playerDirection(self.pawn))
					end
				elseif (self.pawn.charge_birth == 0 and space) then
					self.pawn:give_birth(space)
				else
					self.pawn:walk(math.random(4))
				end
			end
		end
	end;
}
