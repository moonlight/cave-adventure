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
	new = function(self, callInit)
		if (self._instance) then error("new() called on instance, should be called on class.") end

		m_message("Creating new "..self.name)
		local obj = {}
		setmetatable(obj, {__index = self})
		obj._class = self
		obj._instance = true

		if ((callInit or callInit == nil)) then
			-- Assign default properties
			for key, value in pairs(self.defaultproperties) do obj[key] = value; end
			if (obj.init) then obj:init(); end
		end

		return obj
	end;

	-- Makes a class a subclass of this class
	subclass = function(self, t)
		if (self._instance) then error("subclass() called on instance, should be called on class.") end
		if (type(t) ~= "table") then error("subclass() called on class ".. self.name .." with nil value.") end

		-- Set metatable to handle the inheritance
		setmetatable(t, {
			__index = self;
			__call = function(func, ...)
				obj = func:new(unpack(arg))
				return obj
			end
		})

		-- Handle default properties
		local dp = {}
		for key, value in pairs(self.defaultproperties) do dp[key] = value; end
		for key, value in pairs(t.defaultproperties)    do dp[key] = value; end
		t.defaultproperties = dp

		t._superclass = self
		return t
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


	--
	-- DEFAULT PROPERTIES
	--

	defaultproperties = {};
}
