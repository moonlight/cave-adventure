-- player.lua
-- The player object type is defined here.
-- By Bjørn Lindeijer


Player = {}


function Player:event_init()
	inherit(self, BasicChar)
	inherit(self, BasicCharAni)
	self.event_tick = Player.event_tick

	self:start_animation(player_anim);

	self.draw_mode = DM_ALPHA
	
	-- Attributes
	self.strength = 5
	self.dexterity = 5
	self.agility = 5
	self.endurance = 5
	
	self.attack_min_dam = 5
	self.attack_max_dam = 10
	
	self:derive_attributes()

	-- Initial values
	self.travel = 1               -- Player can travel to other maps
	self.experience = 0
	self.nextLevelExperience = 31
	self.health = self.maxHealth

	self.tick_time = 1

	self.charging = 0

	self.state = CHR_READY
	self.pending = CHR_READY
end

function Player:derive_attributes()
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
end

function Player:attack()
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


		SeqControl:add_sequence{
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
end

function Player:setState(state)
	self.state = state

	if (self.state == CHR_ATTACK) then self.attacking = 1
	else self.attacking = 0
	end

	if (self.state == CHR_DEAD) then
		self:do_death()
	end

	self:update_bitmap()
end

function Player:event_tick()
	if (self.charging > 0) then self.charging = self.charging - 1 end
	if (self.state == CHR_READY and self.pending == CHR_ATTACK and self.charging == 0 and self.walking == 0) then
		self.pending = CHR_READY
		self:attack()
	end
	BasicCharAni.event_tick(self)
end

function Player:take_damage(damage)
	if (damage > 0) then
		self.health = self.health - damage
		local obj = m_add_object(self.x, self.y, "BloodSplat")
		obj.offset_z = obj.offset_z + 24

		if (self.health <= 0) then
			self:setState(CHR_DEAD)
		end
	end
end

function Player:do_death()
	self.animation = nil
	self.bitmap = m_get_bitmap("frode_dead.tga")
	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionWait(200),
		ActionSetVariable(game, "game_over", 1),
		ActionAddSequence({
			ActionTweenVariable(game, "game_over_alpha", 300, 255, 0),
		}),
	})
end
