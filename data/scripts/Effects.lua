--
-- Hair raizing sparks, explosions and other effects go in here. :)
--

import("Actor.lua")
import("AnimationFunctions.lua")



--
-- ATTACKS
--

function SpawnSparkyHit(x, y, offset_x, offset_y, offset_z)
	local obj

	--obj = m_add_object(x, y, "BigSpark");
	--obj.offset_x = offset_x
	--obj.offset_y = offset_y
	--obj.offset_z = offset_z

	for i = 1, 10 do
		obj = m_add_object(x, y, "SmallSpark");
		obj.fx = offset_x
		obj.fy = offset_y
		obj.fz = offset_z
	end
end




--
-- Object used for the effects go below here
--

-- A small spark

SmallSpark = {}

function SmallSpark:event_init()
	self.bitmap = m_get_bitmap("spark_small.bmp")
	self.draw_mode = DM_ADD
	self.tick_time = 1
	self.life_time = 50 + math.random(50)

	self.speed_x = (math.random(1000) / 1000 - 0.5) * 0.5
	self.speed_y = (math.random(1000) / 1000 - 0.5) * 0.5
	self.speed_z = (math.random(1000) / 1000 - 0.5) * 0.5

	self.fx = 0.0
	self.fy = 0.0
	self.fz = 0.0
end

function SmallSpark:tick()
	self.life_time = self.life_time - 1
	self.alpha = math.max(0, math.min(255, 255 * self.life_time / 100))

	self.fx = self.fx + self.speed_x
	self.fy = self.fy + self.speed_y
	self.fz = self.fz + self.speed_z
	self.speed_z = self.speed_z - 0.005
	self.offset_x = self.fx
	self.offset_y = self.fy
	self.offset_z = self.fz
	--if (self.fz < 0 and self.speed_z < 0) then self.speed_z = -self.speed_z end

	if (self.life_time < 0) then
		m_destroy_object(self)
	end
end



--
-- A poison projectile
--

PoisonProjectile = Actor:subclass
{
	name = "PoisonProjectile";

	init = function(self)
		self:loopAnim(LinearAnimation(self.animSeq))
	end;

	defaultproperties = {
		draw_mode = DM_MASKED,
		animSeq = {
			m_get_bitmap("spit1.bmp"),
			m_get_bitmap("spit2.bmp"),
		},
		tick_time = 10,
	};
}
