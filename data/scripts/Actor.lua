--
-- The Actor is basically an Object with an part that is present in the
-- engine. Any engine Actor variable that is either assigned or read, is
-- causing transparent assign and read operations to the engine C++ class.
--

import("Object.lua")


-- Helper function for spawning an Actor at a specific position

spawn = function(x, y, class)
	obj = class()
	obj.x = x
	obj.y = y
	return obj
end


-- The Actor class

Actor = Object:subclass
{
	name = "Actor";

	--
	-- CLASS FUNCTIONS
	--

	new = function(self, ...)
		obj = Object.new(self, false)

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

	walk = function(self, dir, no_collision)
		if (no_collision) then
			m_walk_obj_nocol(self, dir)
		else
			m_walk_obj(self, dir)
		end
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
		self.h = h
	end;


	--
	-- DEFAULT PROPERTIES
	--

	defaultproperties = {
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
