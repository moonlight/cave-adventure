--
-- A character is a pawn with a specific animation scheme
-- By Bjorn Lindeijer

import("Pawn.lua")
import("Shadow.lua")


Character = Pawn:subclass
{
	name = "Character";

	init = function(self, char)
		self.inventory = {}

		self:updateBitmap()

		Pawn.init(self)
	end;

	beginPlay = function(self)
		Actor.beginPlay(self)

		if (self.shadowClass) then
			self.shadow = self:spawn(self.shadowClass, self.x, self.y)
		end	
	end;

	updateBitmap = function(self)
		local ani = self.charAnim
		if (ani) then
			if (self.bAttacking) then
				self.bitmap = ani[self.dir + 1 + 3 * 4]
			-- Begin hack for the BBRpg
			elseif (self.bWalkieTalkie) then
				self.bitmap = self.talkieBitmap
			-- End hack for the BBRpg
			else
				if (self.walking == 0 or self.walking < 50) then
					self:setBitmap(ani[self.dir + 1])
				else
					self:setBitmap(ani[self.dir + 1 + (self.leg_used + 1) * 4])
				end
			end
		end
	end;


	event_walk_start = function(self)
		self.leg_used = 1 - self.leg_used
	end;

	event_walk_finished = function(self)
		Pawn.event_walk_finished(self)
		self:updateBitmap()

		-- Check for snow tiles
		local tile = m_get_tile_at(self.map, self.x - 0.5, self.y - 0.5)
		for k,v in pairs(self.snowTiles) do
			if (v == tile) then
				local snowFeet = self:spawn(SnowFeet)
				snowFeet:setDirection(self.dir)
				break
			end
		end
	end;

	event_dir_change = function(self)
		self:updateBitmap()
	end;

	tick = function(self)
		Pawn.tick(self)
		if (self.bSleeping and self.health < self.maxHealth) then
			self.health = math.min(self.health + 0.0001 * self.maxHealth, self.maxHealth)
		end
		self:updateBitmap()
	end;

	died = function(self, killer, damageType, location)
		Pawn.died(self, killer, damageType, location)
		self.charAnim = nil
		self:setBitmap(self.deathBitmap)

		-- There is no shadow after death
		if (self.shadow) then
			self.shadow:destroy()
			self.shadow = nil
		end
	end;

	destroyed = function(self)
		-- Set bDead to prevent AI's from chasing destroyed characters
		self.bDead = true

		Pawn.destroyed(self)

		if (self.shadow) then
			self.shadow:destroy()
			self.shadow = nil
		end
	end;

	setMap = function(self, map)
		Pawn.setMap(self, map)
		if (self.shadow) then
			self.shadow:setMap(map)
		end
	end;

	addToInventory = function(self, obj)
		-- To be implemented?: Check if there is place in the inventory.

		table.insert(self.inventory, obj)

		-- Make the object irrelevant on the map (not perfect)
		obj.bitmap = nil
		obj.obstacle = 0
		obj.bCanActivate = false
		obj.bCarried = true
	end;

-- The loop should probably stop when he finds such an object.
	removeFromInventory = function(self, obj)
		for i,v in ipairs(self.inventory) do
			if (v == obj) then
				table.remove(self.inventory, i)
			end
		end
	end;

	hasObject = function(self, obj)
		for k,v in pairs(self.inventory) do
			if (v == obj) then return true end
		end
	end;

	hasObjectType = function(self, class)
		for k,v in pairs(self.inventory) do
			if (v:instanceOf(class)) then return true end
		end
	end;


	defaultproperties = {
		snowTiles = {
			--"tiles_subcity.000",
			"tiles_subcity.001",
			--"tiles_subcity.002",
			"tiles_subcity.012",
			--"tiles_subcity.013",
			--"tiles_subcity.014",
			"tiles_subcity.016",
			"tiles_subcity.017",
			"tiles_subcity.018",
			"tiles_subcity.021",
			--"tiles_subcity.028",
			"tiles_subcity.029",
			"tiles_subcity.030",
			--"tiles_subcity.032",
			"tiles_subcity.033",
			--"tiles_subcity.034",
			"tiles_subcity.037",
			--"tiles_subcity.045",
			--"tiles_subcity.046",
			"tiles_subcity.063",
			"tiles_subcity.079",
			"tiles_subcity.092",
			"tiles_subcity.125",
			"tiles_subcity.144",
			"tiles_subcity.145",
			"tiles_subcity.147",
			"tiles_subcity.161",
		},
		inventory = nil,
		leg_used = 0,
		tick_time = 1,
		walking = 0,
		charAnim = nil,
		shadow = nil,
		shadowClass = Shadow,
		deathBitmap = nil,

		bAttacking = false,
		bWalkieTalkie = false,
	};
}
