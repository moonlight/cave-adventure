--
-- The root of all classes, introducing basic methods to create subclasses
-- and instaniate an instance of a class. It also includes a method for
-- checking if an object is an instance of a certain class.
--

Object =
{
	name = "Object";

	--
	-- CLASS FUNCTIONS
	--

	-- Creates a new instance of this class
	new = function(self, ...)
		if (self._instance) then error("new() called on instance, should be called on class.") end

		--m_message("Creating new "..self.name)
		local obj = {}
		setmetatable(obj, {__index = self})
		obj._class = self
		obj._instance = true

		-- Assign default properties
		for key, value in pairs(self.defaultproperties) do obj[key] = value; end
		if (obj.init) then obj:init(unpack(arg)); end

		return obj
	end;

	-- Makes a class a subclass of this class
	subclass = function(self, t)
		if (self._instance) then error("subclass() called on instance, should be called on class.") end
		if (type(t) ~= "table") then error("subclass() called on class ".. self.name .." with nil value.") end
		if (not rawget(t, "name")) then error("subclass() called with a class without a name.") end

		-- Set metatable to handle the inheritance
		setmetatable(t, {
			__index = self;

			-- Allow object instaniation by calling the class like a function
			__call = function(func, ...)
				obj = func:new(unpack(arg))
				return obj
			end;
		})

		-- Handle default properties
		local dp = {}
		for key, value in pairs(self.defaultproperties) do dp[key] = value; end
		for key, value in pairs(t.defaultproperties)    do dp[key] = value; end
		t.defaultproperties = dp

		t._superclass = self
		return t
	end;

	-- Checks whether this class is a subclass of a given class
	subclassOf = function(self, t)
		if (self._instance) then error("subclassOf() called on instance, should be called on class.") end
		local class = self
		while (class) do
			if (class == t) then return true end
			class = class._superclass
		end
		return false
	end;


	--
	-- OBJECT FUNCTIONS
	--

	-- Returns whether this object is an instance of the given class
	instanceOf = function(self, t)
		local class = self._class

		while (class) do
			if (class == t) then return true end
			class = class._superclass
		end

		return false
	end;


	-- Writes a message to the log and console
	log = function(self, message)
		if (self._instance) then
			m_message(self:toString()..": "..message)
		else
			m_message(self.name..": "..message)
		end
	end;

	-- Makes a recognizable string
	toString = function(self)
		return self.name
	end;

	-- Return the oposite direction to the given direction
	reverseDirection = function(self, dir)
		if (not dir) then dir = self.dir end
		if (dir == DIR_LEFT)  then return DIR_RIGHT end
		if (dir == DIR_RIGHT) then return DIR_LEFT  end
		if (dir == DIR_UP)    then return DIR_DOWN  end
		if (dir == DIR_DOWN)  then return DIR_UP    end
	end;


	--
	-- DEFAULT PROPERTIES
	--

	defaultproperties = {};
}
