--
-- The player character is defined here.
-- By Bjorn Lindeijer

import("Character.lua")
import("AnimationFunctions.lua")

-- (Player) character states
CHR_ATTACK = 1
CHR_HIT    = 2
CHR_READY  = 3
CHR_DEAD   = 4



Player = Character:subclass
{
	name = "Player";

	init = function(self)
		self:derive_attributes()
		Character.init(self)
	end;

	derive_attributes = function(self)
		-- Derived attributes
		self.maxHealth = 15 + 2*self.endurance
		self.speed = 4/95 * self.agility + 53/19		-- Player speed in tiles/second
		self.charge_time = (-40/95 * self.agility + 60 + 40/19)
		self.attack_speed = self.charge_time/2

		-- Hack to play faster
		self.speed = self.speed * 1.4
		--self.attack_speed = self.attack_speed * 0.5
		--self.charge_time = self.charge_time * 0.5
		--self.maxHealth = self.maxHealth * 100
	end;

	attack = function(self)
		if (self.state == CHR_HIT) then return
		elseif (self.state == CHR_READY and self.walking == 0 and self.charging == 0) then
			self.state = CHR_ATTACK

			-- See if there is a monster at the attacked location
			local ax, ay = self.x, self.y
			if (self.dir == DIR_LEFT)  then ax = ax - 1 end
			if (self.dir == DIR_RIGHT) then ax = ax + 1 end
			if (self.dir == DIR_UP)    then ay = ay - 1 end
			if (self.dir == DIR_DOWN)  then ay = ay + 1 end
			local attacked_objs = m_get_objects_at(ax, ay, self.map)
			for index, object in attacked_objs do
				if (object:instanceOf(Actor)) then
					local damage = (self.attack_min_dam + math.random(self.attack_max_dam - self.attack_min_dam))*(self.strength/95 + 18/19)
					object:takeDamage(damage, self)
				end
			end


			ActionController:addSequence{
				ActionExModeOn(),
				ActionSetState(self, CHR_ATTACK),
				ActionPlaySample("bbsfx_hit1.wav"),
				ActionWait(self.attack_speed),
				ActionSetState(self, CHR_READY),
				ActionSetVariable(self, "charging", self.charge_time),
				ActionExModeOff(),
			}
		end
	end;

	setState = function(self, state)
		self.state = state

		self.bAttacking = (self.state == CHR_ATTACK)

		self:updateBitmap()
	end;

	tick = function(self)
		if (self.charging > 0) then self.charging = self.charging - 1 end
		Character.tick(self)
	end;

	died = function(self, killer, damageType, location)
		Character.died(self, killer, damageType, location)

		if (killer) then
			self:log("Killed by "..killer:toString()..".")
		else
			self:log("Commited suicide.")
		end

		ActionController:addSequence({
			ActionExModeOn(),
			ActionWait(200),
			ActionSetVariable(game, "game_over", 1),
			ActionAddSequence({
				ActionTweenVariable(game, "game_over_alpha", 300, 255, 0),
			}),
		})
	end;

	event_bumped_into = function(self, obj)
		-- Players move away for other players who try to enter this tile
		if (obj:instanceOf(Player)) then
			self:moveAway()
		end
	end;


	gainExperience = function(self, xp)
		self.experience = self.experience + xp

		if (self.experience >= self.nextLevelExperience) then
			self.endurance = self.endurance + 5
			self.nextLevelExperience = 2.5 * self.nextLevelExperience
			self:derive_attributes()
		end
	end;


	defaultproperties =
	{
		sleepBitmap = nil,
		strength = 5,
		dexterity = 5,
		agility = 5,
		endurance = 5,
		experience = 0,
		nextLevelExperience = 31,
		attack_min_dam = 5,
		attack_max_dam = 10,

		charging = 0,

		state = CHR_READY,

		draw_mode = DM_ALPHA,
		tick_time = 1,
		travel = 1,               -- Player can travel to other maps

		charAnim = extr_char_anim(m_get_bitmap("frode.tga")),
	};
}
