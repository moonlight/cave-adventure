--
-- PlayerControllers are used by human players to control pawns.
--
-- By Bjørn Lindeijer

import("Controller.lua")


PlayerController = Controller:subclass
{
	name = "PlayerController";

	-- This is where the input handling takes place. When the player is not
	-- allowed to move (ie. in a cutscene), this function does not get called.
	--
	playerTick = function(self)
		if (self.pawn) then
			if (self.bUp    and self.pawn.walking == 0) then self.pawn:walk(DIR_UP)    end
			if (self.bLeft  and self.pawn.walking == 0) then self.pawn:walk(DIR_LEFT)  end
			if (self.bRight and self.pawn.walking == 0) then self.pawn:walk(DIR_RIGHT) end
			if (self.bDown  and self.pawn.walking == 0) then self.pawn:walk(DIR_DOWN)  end

			if (self.pawn.walking == 0) then
				if (self.bActivate) then                         -- Try activating an object
					local ax, ay = self.pawn.x, self.pawn.y

					if (self.pawn.dir == DIR_LEFT)  then ax = ax - 1 end
					if (self.pawn.dir == DIR_RIGHT) then ax = ax + 1 end
					if (self.pawn.dir == DIR_UP)    then ay = ay - 1 end
					if (self.pawn.dir == DIR_DOWN)  then ay = ay + 1 end

					local objs = m_get_objects_at(ax, ay)
					local activated = false
					local i = 1

					while (i <= table.getn(objs) and not activated) do
						if (objs[i].bCanActivate) then
							objs[i]:activatedBy(self.pawn)
							activated = true                     -- Only activate one object
						end
						i = i + 1
					end
				elseif (self.bAttack) then                       -- Try attacking
					self.pawn:attack(self.pawn.dir)
				end
			end
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