--
-- The Actor is basically an Object with an part that is present in the
-- engine. Any engine Actor variable that is either assigned or read, is
-- causing transparent assign and read operations to the engine C++ class.
--

import("Object.lua")


-- The Actor class

Actor = Object:subclass
{
	name = "Actor";

	--
	-- CLASS FUNCTIONS
	--

	-- Creates a new instance of this class
	new = function(self, ...)
		if (self._instance) then error("new() called on instance, should be called on class.") end

		m_message("Creating new "..self.name)
		local obj = {}
		setmetatable(obj, {__index = self})
		obj._class = self
		obj._instance = true

		-- Setup the binding with the engine
		m_register_object(obj)

		-- Assign default properties
		for key, value in pairs(self.defaultproperties) do obj[key] = value; end
		if (obj.init) then obj:init(unpack(arg)); end

		return obj
	end;


	--
	-- OBJECT FUNCTIONS
	--

	init = function(self)
		self.health = self.maxHealth
	end;

	tick = function(self)
		-- Handle animation
		if (self.currentAnim) then
			if (self.bAnimating) then
				local length = self.currentAnim:length()
				local newTime = self.animTime + self.animSpeed

				if (newTime >= length) then
					if (self.bLoopAnim) then
						self:setAnimTime(newTime - length)
					else
						self:freezeAnimAt(length)
					end
					self:animEnd(self.currentAnim)
				else
					self:setAnimTime(newTime)
				end
			end
		end
	end;


	-- Spawns an actor, defaults to spawning at the spawner's location
	-- and with the spawner as owner.
	--
	spawn = function(self, class, x, y, owner)
		if (not class or type(class) ~= "table") then error("No valid class to spawn specified!") end
		local obj = class:new()

		-- Set position
		if (self._instance or (x and y)) then
			obj:setPosition(x or self.x, y or self.y)
		end

		-- Set owner
		local owner = owner or self
		if (owner) then obj:setOwner(owner) end

		return obj
	end;


	-- The instigator, damageType, momentum and location are all optional.
	--
	takeDamage = function(self, damage, instigator, damageType, momentum, location)
	end;

	died = function(self)
	end;

	destroy = function(self)
		m_destroy_object(self)
	end;


	--== Manipulating this Actor ==--

	setSize = function(self, w, h)
		self.w = w
		self.h = h
	end;

	setPosition = function(self, x, y)
		self.x = x
		self.y = y
	end;

	setOffset = function(self, offset_x, offset_y, offset_z)
		self.offset_x = offset_x
		self.offset_y = offset_y
		self.offset_z = offset_z
	end;

	setOwner = function(self, owner)
		self.owner = owner
	end;


	--== ANIMATION FUNCTIONS ==--

	playAnim = function(self, anim, rate)
		self.currentAnim = anim
		self.animSpeed = rate or 1
		self:setAnimTime(1)
		self.bAnimating = true
	end;

	loopAnim = function(self, anim, rate)
		self:playAnim(anim, rate)
		self.bLoopAnim = true
	end;

	isAnimating = function(self)
		return self.bAnimating
	end;

	finishAnim = function(self)
		self:freezeAnimAt(self.currentAnim:length())
	end;

	stopAnimating = function(self)
		self.bAnimating = false
	end;

	animStopLooping = function(self)
		self.bLoopAnim = false;
	end;

	freezeAnimAt = function(self, time)
		self:setAnimTime(time)
		self:stopAnimating()
	end;

	setAnimTime = function(self, time)
		self.animTime = time
		if (self.currentAnim) then
			self.bitmap = self.currentAnim:getFrameAt(self.animTime)
		end
	end;


	-- Animation notification

	animEnd = function(self, anim)
	end;



	--
	-- DEFAULT PROPERTIES
	--

	defaultproperties = {
		owner = nil,

		speed = 2,
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		offset_x = 0,
		offset_y = 0,
		offset_z = 0,
		draw_mode = DM_MASKED,
		alpha = 255,
		dir = DIR_DOWN,
		tick_time = 0,
		obstacle = 0,
		travel = 0,

		-- Animation variables
		currentAnim = nil,
		bAnimating = false,
		bLoopAnim = false,
		animTime = 0,
		animSpeed = 0,
	};
}
