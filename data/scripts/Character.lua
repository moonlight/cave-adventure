--
-- A base class for anything that walks like a character
-- By Bjørn Lindeijer

import("Actor.lua")


Character = Actor:subclass
{
	name = "Character";

	init = function(self)
		self.health = self.maxHealth
	end;

	-- The instigator, damageType, momentum and location are all optional.
	--
	takeDamage = function(self, damage, instigator, damageType, momentum, location)
		if (damage > 0) then
			local actualDamage = damage
			self.health = self.health - damage

			if (self.health <= 0) then
				-- Character died
				local killer
				if (instigator) then
					killer = instigator.controller
				end
				self:died(killer, damageType, location)
			else
				if (self.controller) then
					self.controller:notifyTakeDamage(actualDamage, instigator, damageType, momentum, location);
				end
			end

			--self:makeNoise(1.0)
		end
	end;

	hearNoise = function(self, loudness, noiseMaker)
		if (self.controller) then
			self.controller:notifyHearNoise(loadness, noiseMaker)
		end
	end;

	died = function(self)
		self:setState(CHR_DEAD)
	end;



	defaultproperties = {
		maxHealth = 100,

		speed = 3,
		offset_y = -6,
		draw_mode = DM_ALPHA,
		obstacle = 1,
	};
}
