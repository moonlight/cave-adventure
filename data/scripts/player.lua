-- player.lua
-- The player class is defined here.
-- By Bjørn Lindeijer

import("Pawn.lua")


Player = Pawn:subclass
{
	name = "Player";

	init = function(self)
		Character.init(self)
		inherit(self, BasicCharAni)

		self.event_tick = Player.event_tick  -- Restore tick function
		self:start_animation(player_anim);
		self:derive_attributes()
		self.health = self.maxHealth
	end;

	derive_attributes = function(self)
		-- Derived attributes
		self.maxHealth = 15 + 2*self.endurance
		self.speed = 4/95 * self.agility + 53/19		-- Player speed in tiles/second
		self.charge_time = (-40/95 * self.agility + 60 + 40/19)
		self.attack_speed = self.charge_time/2

		-- Hack to play faster
		--self.speed = self.speed * 2
		--self.attack_speed = self.attack_speed * 0.5
		--self.charge_time = self.charge_time * 0.5
		--self.maxHealth = self.maxHealth * 100
	end;

	attack = function(self)
		--m_message("Attack function called!");
		if (self.state == CHR_HIT) then return
		elseif (self.state == CHR_READY and self.walking == 0 and self.charging == 0) then
			self.state = CHR_ATTACK

			-- See if there is a monster at the attacked location
			local ax, ay = self.x, self.y
			if (self.dir == DIR_LEFT)  then ax = ax - 1 end
			if (self.dir == DIR_RIGHT) then ax = ax + 1 end
			if (self.dir == DIR_UP)    then ay = ay - 1 end
			if (self.dir == DIR_DOWN)  then ay = ay + 1 end
			local attacked_objs = m_get_objects_at(ax, ay)
			for index, object in attacked_objs do
				if (object.take_damage) then
					local damage = (self.attack_min_dam + math.random(self.attack_max_dam - self.attack_min_dam))*(self.strength/95 + 18/19)
					object:take_damage(damage)
				end
			end


			ActionController:addSequence{
				ActionExModeOn(),
				ActionSetState(self, CHR_ATTACK),
				ActionWait(self.attack_speed),
				ActionSetState(self, CHR_READY),
				ActionSetVariable(self, "charging", self.charge_time),
				ActionExModeOff(),
			}
		elseif (self.state == CHR_READY) then
			-- Either charging or walking, attack after that
			--self.pending = CHR_ATTACK
		end
	end;

	setState = function(self, state)
		self.state = state

		if (self.state == CHR_ATTACK) then self.attacking = 1
		else self.attacking = 0
		end

		self:update_bitmap()
	end;

	event_tick = function(self)
		if (self.charging > 0) then self.charging = self.charging - 1 end
		if (self.state == CHR_READY and self.pending == CHR_ATTACK and self.charging == 0 and self.walking == 0) then
			self.pending = CHR_READY
			self:attack()
		end
		BasicCharAni.event_tick(self)
	end;

	takeDamage = function(self, damage, instigator, damageType, momentum, location)
		Pawn.takeDamage(self, damage, instigator, damageType, momentum, location)
		if (damage > 0) then
			local obj = m_add_object(self.x, self.y, "BloodSplat")
			obj.offset_z = obj.offset_z + 24
		end
	end;

	died = function(self)
		self:setState(CHR_DEAD)
		self.animation = nil
		self.bitmap = m_get_bitmap("frode_dead.tga")
		ActionController:addSequence({
			ActionExModeOn(),
			ActionWait(200),
			ActionSetVariable(game, "game_over", 1),
			ActionAddSequence({
				ActionTweenVariable(game, "game_over_alpha", 300, 255, 0),
			}),
		})
	end;


	defaultproperties =
	{
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
		pending = CHR_READY,

		draw_mode = DM_ALPHA,
		tick_time = 1,
		travel = 1,               -- Player can travel to other maps
	}
}