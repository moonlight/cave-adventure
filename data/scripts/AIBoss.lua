--
-- A modified AI implementation for the boss
--


-- Common states for the boss

BAI_WAITING = 1 -- Initial state, doing nothing (a sequence will have to set it to BAI_READY
BAI_WALKING = 2 -- Though the boss just floats
BAI_ATTACK  = 3 -- Attacking the player
BAI_DEAD    = 4 -- Dead
BAI_HIT     = 5 -- Getting hit by the player
BAI_READY   = 6 -- Basically in a loop to figure out what to do
BAI_PHASE   = 7 -- Teleporting to a better spot



BossAI = {}

function BossAI:event_init()
	--inherit(self, LinearAni)
	self.state = AI_READY
	self.tick_time = 1

	self.charge = 0
	self.charge_time = 200
	self.attack_time = 50
	self.attack_range = 3
	self.attack_min_dam = 1
	self.attack_max_dam = 3

	self.health = 100
	self.maxHealth = self.health

	self.teleport_interval = 200
	self.teleport_countdown = 0
	self.teleport_sequence = nil

	-- The area in which the boss can teleport
	self.area_min_x = 31
	self.area_min_y = 9
	self.area_max_x = 39
	self.area_max_y = 16

	-- Hovering
	self.offset_z = 0
	self.goal_z = 12
	self.count_z = 0

	-- Shadow
	self.shadow = m_add_object(self.x, self.y, "BossShadow")
	self.shadow.offset_z = -24
end

function BossAI:event_destroyed()
	-- Remove shadow
	m_destroy_object(self.shadow)
end

function BossAI:tick()
	-- Hover up
	if (self.count_z < self.goal_z) then self.count_z = self.count_z + 0.1 end
	if (self.count_z > self.goal_z) then self.count_z = self.count_z - 0.1 end
	self.offset_z = self.count_z

	-- Keep schadow along with me
	self.shadow.x = self.x
	self.shadow.y = self.y - 1
	self.shadow.offset_x = self.offset_x
	self.shadow.offset_y = self.offset_y
	self.shadow.alpha = self.alpha

	-- Countdown charge
	if (self.charge > 0) then self.charge = self.charge - 1 end
	if (self.teleport_countdown > 0) then self.teleport_countdown = self.teleport_countdown - 1 end

	-- Switch to ready from walking (or, hovering)
	if (self.state == AI_WALKING and self.walking == 0) then
		self:setState(AI_READY)
	end

	-- When an boss is ready and player not dead, he's not waiting for something to happen to take action
	if (self.state == AI_READY and player.state ~= CHR_DEAD) then
		-- Check if player is drawing near (then, when teleport possible: teleport randomly away to a place not player occupied)
		playerDist = playerDistance(self)
		local player = m_get_player()

		if (playerDist < 2) then
			if (self.teleport_countdown == 0) then
				-- We can teleport away, so let's do it!
				-- Pick a math.random spot (TODO: make sure not close or on top of player)
				local tx = self.area_min_x + math.random(self.area_max_x - self.area_min_x)
				local ty = self.area_min_y + math.random(self.area_max_y - self.area_min_y)
				-- Do the teleport sequence
				self:setState(BAI_PHASE)
				self.teleport_sequence = ActionController:addSequence({
					ActionSetVariable(self, "draw_mode", DM_TRANS),
					ActionTweenVariable(self, "alpha", 50, 0),
					ActionSetPosition(self, tx, ty),
					ActionTweenVariable(self, "alpha", 50, 255),
					ActionSetVariable(self, "draw_mode", DM_MASKED),
					ActionSetVariable(self, "teleport_countdown", math.random(self.teleport_interval) + 100),
					ActionSetState(self, BAI_READY),
				})
			else
				-- We could try to hover away
				self:walk(reverseDirection(playerDirection(self)))
			end
		else
			-- Player not close, so let's cast a spell on him! (muhahaha)
			if (self.charge == 0) then
				self:attack(playerDirection(self))
			else
				-- Not charged up, hover randomly!
				self:walk(math.random(4))
			end
		end
	end
end

function BossAI:attack(dir)
	m_message("AI attacking!");
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

function BossAI:walk(dir)
	m_walk_obj(self, dir)
	self:setState(AI_WALKING)
end

function BossAI:update_bitmap()
end

function BossAI:setState(state)
	self.state = state
	
	if (self.state == AI_ATTACK) then self.attacking = 1 else self.attacking = 0 end
	self:update_bitmap()

	if (self.state == AI_DEAD) then
		-- Get rid of any teleport sequences
		ActionController:removeSequence(self.teleport_sequence)
		--self.tick_time = 0
		self:do_death()
	end
end

function BossAI:take_damage(amount)
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
		end
	end
end
