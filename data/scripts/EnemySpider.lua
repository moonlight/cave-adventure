-- Some spiders
-- By Bjorn Lindeijer

import("Enemy.lua")
import("AIController.lua")
import("QueenController.lua")
import("effects.lua")


EnemySpider = Enemy:subclass
{
	name = "EnemySpider";

	--[[
	attack = function(self)
		--m_message("AI attacking!");
		self:setState(AI_ATTACK)
		--local player = m_get_player()

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
	]]

	defaultproperties = {
		offset_y = 6,

		experience = 8,
		speed = 3,
		maxHealth = 25,
		chargeTime = 200,
		charge = 0,
		attack_range = 1,
		attackTime = 50,
		attack_min_dam = 1,
		attack_max_dam = 3,

		draw_mode = DM_MASKED,
		charAnim = extr_char_anim(m_get_bitmap("spider.bmp"), 24, 24),
		deathBitmap = m_get_bitmap("spider_dead.bmp"),

		hitEffectClass = BloodSplatGreen,
		hitEffectHeight = 8,

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
		local blob = self:spawn(PoisonProjectile, self.x, self.y)
		blob.offset_y = self.offset_y - 5

		ActionController:addSequence({
			ActionAddSequence{
				ActionTweenVariable(blob, "offset_x", 50, (obj.x - self.x) * 24, self.offset_x)
			},
			ActionAddSequence{
				ActionTweenVariable(blob, "offset_y", 50, (obj.y - self.y) * 24 - 15, self.offset_y - 5),
				ActionDestroyObject(blob),
			},
		})
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
		local blob = self:spawn(PoisonProjectile, self.x, self.y)
		blob.offset_y = self.offset_y - 5

		ActionController:addSequence({
			ActionAddSequence{
				ActionTweenVariable(blob, "offset_x", 50, (obj.x - self.x) * 24, self.offset_x)
			},
			ActionAddSequence{
				ActionTweenVariable(blob, "offset_y", 50, (obj.y - self.y) * 24 - 15, self.offset_y - 5),
				ActionDestroyObject(blob),
			},
		})
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
