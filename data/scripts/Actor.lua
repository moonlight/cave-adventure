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
		self:destroy()
	end;

	destroy = function(self)
		m_destroy_object(self)
	end;

	setSize = function(self, w, h)
		self.w = w
		self.h = h
	end;

	setPosition = function(self, x, y)
		self.x = x
		self.y = y
	end;

	setOwner = function(self, owner)
		self.owner = owner
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
	};
}
