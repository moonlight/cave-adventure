--
-- Caveman classes
-- By Bjorn Lindeijer

import("Enemy.lua")
import("AnimationFunctions.lua")


Caveman = Character:subclass
{
	name = "Caveman";

	defaultproperties = {
		draw_mode = DM_MASKED,
		speed = 2,
		charAnim = extr_char_anim(m_get_bitmap("caveman.bmp")),
	};
}




--
-- The caveman enemy object
--

EnemyCaveman = Enemy:subclass
{
	name = "EnemyCaveman";

	setState = function(self, state)
		self.state = state
		
		if (self.state == AI_ATTACK) then self.attacking = 1 else self.attacking = 0 end
		self:updateBitmap()
	end;

	died = function(self, killer)
		Enemy.died(self, killer)
		self.offset_y = self.offset_y + 3
	end;

	attack = function(self, obj)
		if (obj) then
			SpawnSparkyHit(obj.x, obj.y, obj.offset_x, obj.offset_y, obj.offset_z + 24)
		end
	end;

	defaultproperties = {
		experience = 17,
		draw_mode = DM_MASKED,
		speed = 2,
		charAnim = extr_char_anim(m_get_bitmap("caveman.bmp")),
		deathBitmap = m_get_bitmap("caveman_dead.bmp"),
	};
}



--
-- The caveman slave object
--

CavemanSlave = Character:subclass
{
	name = "CavemanSlave";

	defaultproperties = {
		draw_mode = DM_MASKED,
		speed = 2,
		charAnim = extr_char_anim(m_get_bitmap("caveman_slave.bmp")),
	};
}



--
-- A dead slave
--

SlaveDead = Character:subclass
{
	name = "SlaveDead";

	defaultproperties = {
		draw_mode = DM_MASKED,
		bitmap = m_get_bitmap("slave_dead.bmp"),
	};
}
