-- spider.lua
-- By Bjørn Lindeijer


--
-- The spider enemy object
--

EnemySpider = {}

function EnemySpider:event_init()
	inherit(self, CommonAIChar)
	self:event_init()

	-- Set our own common options
	self.attack_range = 1
	self.speed = 3
	self.experience = 8

	self.draw_mode = DM_MASKED
	self:start_animation(spider_anim)
end

function EnemySpider:do_death()
	self.animation = nil
	self.bitmap = m_get_bitmap("spider_dead.bmp")
	SeqControl:add_sequence({
		ActionWait(100),
		ActionSetVariable(self, "draw_mode", DM_TRANS),
		ActionTweenVariable(self, "alpha", 200, 0),
		ActionDestroyObject(self),
	})
end

function EnemySpider:do_hit()
	local obj = m_add_object(self.x, self.y, "BloodSplatGreen")
	obj.offset_z = obj.offset_z + 12
end


--
-- A poisonous spider
--

EnemyPoisonSpider = {}

function EnemyPoisonSpider:event_init()
	inherit(self, CommonAIChar)
	self:event_init(self)

	-- Set our own common options
	self.attack_range = 2
	self.attack_min_damage = 0
	self.attack_max_damage = 0

	self.draw_mode = DM_MASKED
	self.speed = 2.5
	self.experience = 11

	self:start_animation(spider2_anim)
end

function EnemyPoisonSpider:attack_object(obj)
	ShootPoison(self, obj)
end

function EnemyPoisonSpider:do_death()
	self.animation = nil
	self.bitmap = m_get_bitmap("spider2_dead.bmp")
	SeqControl:add_sequence({
		ActionWait(100),
		ActionSetVariable(self, "draw_mode", DM_TRANS),
		ActionTweenVariable(self, "alpha", 200, 0),
		ActionDestroyObject(self),
	})
end

function EnemyPoisonSpider:do_hit()
	local obj = m_add_object(self.x, self.y, "BloodSplatYellow")
	obj.offset_z = obj.offset_z + 12
end

--
-- A poisonous spider queen
--

EnemyPoisonSpiderQueen = {}

function EnemyPoisonSpiderQueen:event_init()
	inherit(self, BasicChar)
	inherit(self, BasicCharAni)
	inherit(self, CommonAI)

	self.event_tick = EnemyPoisonSpiderQueen.event_tick
	self:event_init(self)

	-- Set our own common options
	self.attack_range = 2
	self.attack_min_damage = 0
	self.attack_max_damage = 0
	self.charge_birth = 0
	self.experience = 13

	self.draw_mode = DM_MASKED
	self.speed = 2.2
	self:start_animation(spider3_anim)
end

function EnemyPoisonSpiderQueen:attack_object(obj)
	ShootPoison(self, obj)
end

function EnemyPoisonSpiderQueen:event_tick()
	BasicCharAni.event_tick(self)

	if (self.charge > 0) then self.charge = self.charge - 1 end
	if (self.charge_birth > 0) then self.charge_birth = self.charge_birth - 1 end

	-- Switch to ready from walking
	if (self.state == AI_WALKING and self.walking == 0) then
		self:setState(AI_READY)
	end

	-- When an AI is ready, it's waiting for something to happen to take action
	if (self.state == AI_READY) then
		-- Check if player is drawing near
		playerDist = playerDistance(self)
		local player = m_get_player()

		if (playerDist < 5 and player.state ~= CHR_DEAD) then
			local space = randomFreeTileAround(self)

			-- Chase or attack?
			if (playerDist <= self.attack_range) then
				-- Attack on charged
				if (self.charge == 0 and self.walking == 0) then
					self:attack(playerDirection(self))
				end
			elseif (self.charge_birth == 0 and space) then
				self:give_birth(space)
			else
				self:walk(math.random(4))
			end
		end
	end
end

function EnemyPoisonSpiderQueen:give_birth(dir)
	local obj = m_add_object(self.x, self.y, "EnemySmallPoisonSpiderQueen")
	obj:walk(dir)
	self.charge_birth = 300 + math.random(200)
end

function EnemyPoisonSpiderQueen:do_death()
	self.animation = nil
	self.bitmap = m_get_bitmap("spider3_dead.bmp")
	SeqControl:add_sequence({
		ActionWait(100),
		ActionSetVariable(self, "draw_mode", DM_TRANS),
		ActionTweenVariable(self, "alpha", 200, 0),
		ActionDestroyObject(self),
	})
end

function EnemyPoisonSpiderQueen:do_hit()
	local obj = m_add_object(self.x, self.y, "BloodSplatYellow")
	obj.offset_z = obj.offset_z + 12
end

--
-- A small poisonous spider queen
--

EnemySmallPoisonSpiderQueen = {}

function EnemySmallPoisonSpiderQueen:event_init()
	inherit(self, CommonAIChar)
	self:event_init(self)

	-- Set our own common options
	self.attack_range = 1
	self.attack_min_damage = 0
	self.attack_max_damage = 0
	self.experience = 5

	self.draw_mode = DM_MASKED
	self.speed = 3
	self:start_animation(spider_small_anim)
end

function EnemySmallPoisonSpiderQueen:attack_object(obj)
	ShootPoison(self, obj)
end

function EnemySmallPoisonSpiderQueen:do_death()
	self.animation = nil
	self.bitmap = m_get_bitmap("spider_small_dead.bmp")
	SeqControl:add_sequence({
		ActionWait(100),
		ActionSetVariable(self, "draw_mode", DM_TRANS),
		ActionTweenVariable(self, "alpha", 200, 0),
		ActionDestroyObject(self),
	})
end

function EnemySmallPoisonSpiderQueen:do_hit()
	local obj = m_add_object(self.x, self.y, "BloodSplatYellow")
	obj.offset_z = obj.offset_z + 7
end