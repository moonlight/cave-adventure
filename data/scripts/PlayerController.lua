--
-- PlayerControllers are used by human players to control pawns.
--
-- By Bjorn Lindeijer

import("Controller.lua")


PlayerController = Controller:subclass
{
	name = "PlayerController";

	-- This is where the input handling takes place. When the player is not
	-- allowed to move (ie. in a cutscene), this function does not get called.
	--
	
	playerTick = function(self)
		if (self.pawn and not self.pawn.bDead) then
			if (not self.pawn.bSleeping) then
				if (self.bUp    and self.pawn.walking == 0) then self.pawn:walk(DIR_UP)    end
				if (self.bLeft  and self.pawn.walking == 0) then self.pawn:walk(DIR_LEFT)  end
				if (self.bRight and self.pawn.walking == 0) then self.pawn:walk(DIR_RIGHT) end
				if (self.bDown  and self.pawn.walking == 0) then self.pawn:walk(DIR_DOWN)  end
			end

			if (self.pawn.walking == 0) then
				if (self.bActivate and not self.bActivatePrev) then                         -- Try activating an object
					local ax, ay = self.pawn.x, self.pawn.y
					
					if (self.pawn.onActivate) then
						self.pawn:onActivate()
					elseif (not self.pawn.bSleeping) then
						if (self.pawn.dir == DIR_LEFT)  then ax = ax - 1 end
						if (self.pawn.dir == DIR_RIGHT) then ax = ax + 1 end
						if (self.pawn.dir == DIR_UP)    then ay = ay - 1 end
						if (self.pawn.dir == DIR_DOWN)  then ay = ay + 1 end

						local objs = m_get_objects_at(ax, ay, self.pawn.map)
						local activated = false
						local i = 1

						while (i <= #objs and not activated) do
							if (objs[i].bCanActivate) then
								-- By returning true, an object can indicate nothing else should be activated
								-- after this one.
								activated = objs[i]:activatedBy(self.pawn)
							end
							i = i + 1
						end
					end
				elseif (self.bAttack and not self.pawn.bSleeping) then                       -- Try attacking
					self.pawn:attack(self.pawn.dir)
				end
			end

			self.bActivatePrev = self.bActivate			
		end
	end;



	defaultproperties =
	{
		-- Input variables
		bUp       = false,
		bLeft     = false,
		bRight    = false,
		bDown     = false,
		bActivate = false,
		bAttack   = false,
	}
}
