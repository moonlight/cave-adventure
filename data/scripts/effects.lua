-- effects.lua
-- Hair raizing sparks, explosions and other effects go in here. :)
--


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

function ShootPoison(from_obj, to_obj)
	local blob = m_add_object(from_obj.x, from_obj.y, "PoisonProjectile")
	blob.offset_y = from_obj.offset_y - 5

	SeqControl:add_sequence({
		ActionAddSequence{
			ActionTweenVariable(blob, "offset_x", 50, (to_obj.x - from_obj.x) * 24, from_obj.offset_x)
		},
		ActionAddSequence{
			ActionTweenVariable(blob, "offset_y", 50, (to_obj.y - from_obj.y) * 24 - 15, from_obj.offset_y - 5),
			ActionDestroyObject(blob),
		},
	})
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

function SmallSpark:event_tick()
	self.life_time = self.life_time - 1
	self.alpha = max(0, min(255, 255 * self.life_time / 100))

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
-- Some bloody splats
--
BloodSplat = {}
function BloodSplat:event_init()
	inherit(self, LinearAni)
	self:start_animation(blood_splat_anim)
	self.tick_time = 7
end
function BloodSplat:animation_finished()
	m_destroy_object(self)
end

BloodSplatGreen = {}
function BloodSplatGreen:event_init()
	BloodSplat.event_init(self)
	self.animation_finished = BloodSplat.animation_finished
	self:start_animation(blood_splat_green_anim)
end

BloodSplatYellow = {}
function BloodSplatYellow:event_init()
	BloodSplat.event_init(self)
	self.animation_finished = BloodSplat.animation_finished
	self:start_animation(blood_splat_yellow_anim)
end


--
-- A poison projectile
--
PoisonProjectile = {}
function PoisonProjectile:event_init()
	inherit(self, LinearAni)
	self.draw_mode = DM_MASKED
	self:start_animation({m_get_bitmap("spit1.bmp"), m_get_bitmap("spit2.bmp")})
	self.tick_time = 10
end
