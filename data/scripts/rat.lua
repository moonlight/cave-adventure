-- rat.lua
-- A rat.
-- Editted by Frode Lindeijer

Rat = {}

function Rat:event_init()
	inherit(self, BasicChar)
	inherit(self, BasicCharAni)
	inherit(self, CommonAI)

	CommonAI.event_init(self)

	self.take_damage = Rat.take_damage

	self.draw_mode = DM_MASKED
	self.speed = 1.5
	self:start_animation(rat_anim)

	self.scared = false
	self.walk_interval = 100 + random(50)
end

function Rat:do_death()
	m_message("Rat death")

	self.animation = nil
	self.bitmap = m_get_bitmap("rat_dead.bmp")
	SeqControl:add_sequence({
		ActionWait(100),
		ActionSetVariable(self, "draw_mode", DM_TRANS),
		ActionTweenVariable(self, "alpha", 200, 0),
		ActionDestroyObject(self),
	})
end

function Rat:event_tick()
	m_message("Rat tick")

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

		if (playerDist < 5 and scared == true) then
			self:walk(reverseDirection(playerDirection(self)))
		elseif (self.walk_interval == 0) then
			self:walk(random(4))
			self.walk_interval = 100 + random(50)
		end
	end

	if (self.walk_interval > 0) then
		self.walk_interval = self.walk_interval - 1
	end
end

function Rat:take_damage(amount)
	m_message("Rat take damage")
	
	self.scared = true
	CommonAI.take_damage(self, amount)
end