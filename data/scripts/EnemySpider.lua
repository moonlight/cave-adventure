-- Some spiders
-- By Bjørn Lindeijer

import("Character.lua")
import("AIController.lua")
import("QueenController.lua")
import("effects.lua")


EnemySpider = Character:subclass
{
	name = "EnemySpider";

	takeDamage = function(self, damage, instigator, damageType, momentum, location)
		m_message("Spider took ".. damage .." damage")
		if (self.state ~= AI_DEAD) then
			Character.takeDamage(self, damage, instigator, damageType, momentum, location)
			if (damage > 0) then
				local obj = self:spawn(self.hitEffectClass, self.x, self.y)
				obj.offset_z = obj.offset_z + 12
			end
		end
	end;

	died = function(self, killer, damageType, location)
		self:setState(AI_DEAD)
		local player = m_get_player()

		player.experience = player.experience + self.experience
		if (player.experience >= player.nextLevelExperience) then
			player.endurance = player.endurance + 5
			player.nextLevelExperience = 2.5 * player.nextLevelExperience
			player:derive_attributes()
		end

		self.charAnim = nil
		self.bitmap = self.deathBitmap
		ActionController:addSequence({
			ActionWait(100),
			ActionSetVariable(self, "draw_mode", DM_TRANS),
			ActionTweenVariable(self, "alpha", 200, 0),
			ActionDestroyObject(self),
		})

		self.tick_time = 0
	end;

	attack = function(self)
		--m_message("AI attacking!");
		self:setState(AI_ATTACK)
		local player = m_get_player()

		-- Handle attack (deal damage to player)
		player:takeDamage(self.attack_min_dam + math.random(self.attack_max_dam - self.attack_min_dam))

		-- Spawn the hitting effect (ie. sparks)
		if (self.attack_object) then self:attack_object(player) end

		ActionController:addSequence{
			ActionWait(self.attack_time),
			ActionSetState(self, AI_READY),
			ActionSetVariable(self, "charge", self.charge_time),
		}
	end;

	walk = function(self, dir)
		Character.walk(self, dir)
		self:setState(AI_WALKING)
	end;

	setState = function(self, state)
		self.state = state
		
		if (self.state == AI_ATTACK) then self.attacking = 1 else self.attacking = 0 end
		self:updateBitmap()
	end;

	defaultproperties = {
		state = AI_READY,
		tick_time = 1,

		experience = 8,
		speed = 3,
		maxHealth = 25,
		charge_time = 200,
		charge = 0,
		attack_range = 1,
		attack_time = 50,
		attack_min_dam = 1,
		attack_max_dam = 3,

		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("spider.bmp"), 24, 24),
		deathBitmap = m_get_bitmap("spider_dead.bmp"),
		hitEffectClass = BloodSplatGreen,

		controllerClass = AIController,
	};
}




--
-- A poisonous spider
--

EnemyPoisonSpider = EnemySpider:subclass
{
	name = "EnemyPoisonSpider";

	attack_object = function(self, obj)
		ShootPoison(self, obj)
	end;

	defaultproperties = {
		experience = 11,
		attack_range = 2,
		attack_min_damage = 0,
		attack_max_damage = 0,
		speed = 2.5,

		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("spider2.bmp"), 24, 24),
		deathBitmap = m_get_bitmap("spider2_dead.bmp"),
		hitEffectClass = BloodSplatYellow,
	};
}


--
-- A poisonous spider queen
--

EnemyPoisonSpiderQueen = EnemySpider:subclass
{
	name = "EnemyPoisonSpiderQueen";

	attack_object = function(self, obj)
		ShootPoison(self, obj)
	end;

	give_birth = function(self, dir)
		local obj = self:spawn(EnemySmallPoisonSpiderQueen, self.x, self.y)
		obj:walk(dir)
		self.charge_birth = 300 + math.random(200)
	end;

	defaultproperties = {
		experience = 13,
		attack_range = 2,
		attack_min_damage = 0,
		attack_max_damage = 0,
		charge_birth = 0,
		speed = 2.2,

		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("spider3.bmp"), 24, 24),
		deathBitmap = m_get_bitmap("spider3_dead.bmp"),
		hitEffectClass = BloodSplatYellow,

		controllerClass = QueenController,
	};
}



--
-- A small poisonous spider queen
--

EnemySmallPoisonSpiderQueen = EnemyPoisonSpider:subclass
{
	name = "EnemySmallPoisonSpiderQueen";

	defaultproperties = {
		experience = 5,
		attack_range = 1,
		attack_min_damage = 0,
		attack_max_damage = 0,
		speed = 3,

		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("spider_small.bmp"), 16, 16),
		deathBitmap = m_get_bitmap("spider_small_dead.bmp"),
		hitEffectClass = BloodSplatYellow,
	};
}
