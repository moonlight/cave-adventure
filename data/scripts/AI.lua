--
-- Our 'magnificent' AI implementation
--


-- Common states for an AI monster

AI_WAITING = 1
AI_WALKING = 2
AI_ATTACK  = 3
AI_DEAD    = 4
AI_HIT     = 5
AI_READY   = 6






CommonAI = {}

function CommonAI:event_init()
	self.state = AI_READY
	self.tick_time = 1
	self.charge = 0
	self.charge_time = 200
	self.attack_time = 50
	self.attack_range = 3
	self.attack_min_dam = 1
	self.attack_max_dam = 3
	self.health = 25
	self.maxHealth = self.health
end

function CommonAI:tick()
	if (self.charge > 0) then self.charge = self.charge - 1 end

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
			-- Chase or attack?
			if (playerDist <= self.attack_range) then
				-- Attack on charged
				if (self.charge == 0 and self.walking == 0) then
					self:attack(playerDirection(self))
				end
			else
				self:walk(playerDirection(self))
			end
		end
	end
end

function CommonAI:attack(dir)
	--m_message("AI attacking!");
	self.dir = dir
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
end

function CommonAI:walk(dir)
	m_walk_obj(self, dir)
	self:setState(AI_WALKING)
end

function CommonAI:setState(state)
	self.state = state
	
	if (self.state == AI_ATTACK) then self.attacking = 1 else self.attacking = 0 end
	self:update_bitmap()

	if (self.state == AI_DEAD) then
		if (self.do_death) then self:do_death()
		else
			self.animation = nil
			ActionController:addSequence({
				ActionWait(100),
				ActionSetVariable(self, "draw_mode", DM_TRANS),
				ActionTweenVariable(self, "alpha", 200, 0),
				ActionDestroyObject(self),
			})
		end
		self.tick_time = 0
	end
end

function CommonAI:take_damage(amount)
	if (self.state ~= AI_DEAD) then
		-- Should probably suspend a little when being hit
		--self:setState(AI_HIT)

		self.health = self.health - amount

		-- Spawn the getting hit effect (ie. blood)
		if (self.do_hit) then self:do_hit()
		else
			local obj = m_add_object(self.x, self.y, "BloodSplat")
			obj.offset_z = obj.offset_z + 12
		end

		if (self.health <= 0) then
			self:setState(AI_DEAD)
			local player = m_get_player()
			player.experience = player.experience + self.experience
			if (player.experience >= player.nextLevelExperience) then
				player.endurance = player.endurance + 5
				player.nextLevelExperience = 2.5 * player.nextLevelExperience
				player:derive_attributes()
			end
		end
	end
end
