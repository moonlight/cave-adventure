--
-- Here are defined the most simple and generic actions that
-- could be used in a sequence. Feel free to define more specific
-- actions for your own sequences.
--
-- All actions have a finished() function indicating whether they
-- are finished. Non-instant actions also have an exec() function
-- that will be called every game tick until their finished()
-- function returns 1.
--
-- A summaration of the available action types follows:
--
--   ActionSequence(sequence)
--   ActionAddSequence(sequence)
--   ActionCallFunction(f, ...)
--   ActionSetVariable(table, key, value)
--   ActionTweenVariable(table, key, time, to [, from])
--   ActionWait(duration)
--
--   ActionChangeBitmap(actor, bitmap)
--   ActionChangeDirection(actor, new_direction)
--   ActionWalk(actor, direction, amount [,col])
--   ActionConversation(conversation)
--   ActionExModeOn()
--   ActionExModeOff()
--   ActionPlaySong(filename, fadeTime [, wait])
--   ActionFadeOutMusic(fadeTime [, wait])
--   ActionFadeInMusic(filename, fadeTime [, wait])
--   ActionFadeInMap(time)
--   ActionFadeOutMap(time)
--   ActionSetState(object, state)
--   ActionSetPosition(actor, x, y [, dir])
--   ActionChangeMap(filename)
--   ActionDestroyObject(object)
--   ActionAddObject({name|class}, x, y)
--   ActionQuitGame()
--   ActionShowMapName(bitmap)
--
-- By Bjørn Lindeijer


import("Object.lua")


Action = Object:subclass
{
	name = "Action";

	-- The init function is generally used to store the arguments.
	init = function(self) end;

	-- The exec function will be called every game tick until it returns true.
	exec = function(self) end;
}


-- Execute a sequence of actions

ActionSequence = Action:subclass
{
	name = "ActionSequence";

	init = function(self, seq)
		m_message("ActionSequence initializing with ".. table.getn(seq) .." actions.")
		self.actions = {}

		for i = 1, table.getn(seq) do
			local env = {}
			setmetatable(env, {__index = seq[i]})
			table.insert(self.actions, env)
		end

		self.i = 1
	end;

	exec = function(self)
		while (self.i <= table.getn(self.actions) and self.actions[self.i]:exec()) do
			m_message("ActionSequence finished executing ".. self.actions[self.i].name)
			self.i = self.i + 1
		end

		return (self.i > table.getn(self.actions))
	end;
}


-- Add a sequence to the sequence controller

ActionAddSequence = Action:subclass
{
	name = "ActionAddSequence";

	init = function(self, seq)
		self.sequence = seq
	end;

	exec = function(self)
		ActionController:addSequence(seq)
		return true
	end;
}


-- Calling a function

ActionCallFunction = Action:subclass
{
	name = "ActionCallFunction";

	init = function(self, f, ...)
		self.f = f
		self.arg = arg
	end;

	exec = function(self)
		self.f(expand(self.arg))
		return true
	end;
}


-- Set a specified variable of a certain table to a specific value

ActionSetVariable = Action:subclass
{
	name = "ActionSetVariable";

	init = function(self, table, key, value)
		self.table = table
		self.key = key
		self.value = value
	end;

	exec = function(self)
		if (self.table) then self.table[self.key] = self.value end
		return true
	end;
}


-- Tween a specified variable of a certain object to a specific value

ActionTweenVariable = Action:subclass
{
	name = "ActionTweenVariable";

	init = function(self, table, key, time, to, from)
		self.table = table
		self.key = key
		self.time = time
		self.to = to
		self.from = from

		self.count = 0
	end;
	
	exec = function(self)
		if (not self.from) then self.from = self.table[self.key] end

		self.count = self.count + 1
		if (self.count <= self.time) then
			self.table[self.key] = self.from + ((self.count / self.time) * (self.to - self.from))
		else
			self.table[self.key] = self.to
		end

		return (self.count > self.time)
	end;
}


-- Pause for <duration> game ticks

ActionWait = Action:subclass
{
	name = "ActionWait";

	init = function(self, duration)
		self.duration = duration
		self.timer = 0
	end;
	
	exec = function(self)
		self.timer = self.timer + 1
		return (self.timer > self.duration)
	end;
}


-- Change the bitmap of a single object

ActionChangeBitmap = ActionSetVariable:subclass
{
	name = "ActionChangeBitmap";
	init = function(self, object, bitmap)
		ActionSetVariable.init(self, object, "bitmap", bitmap)
	end;
}

-- Change the direction of a single object

ActionChangeDirection = ActionSetVariable:subclass
{
	name = "ActionChangeDirection";
	init = function(self, object, direction)
		ActionSetVariable.init(self, object, "dir", direction)
	end;
}


-- Order characters around.

ActionWalk = Action:subclass
{
	name = "ActionWalk";

	init = function(self, object, direction, amount, col)
		self.object = object
		self.direction = direction
		self.amount = amount
		self.col = (col ~= nil and col ~= 0)
	end;

	exec = function(self)
		if (self.object.walking == 0 and self.amount > 0) then
			if (self.col) then
				m_walk_obj(self.object, self.direction)
			else
				m_walk_obj_nocol(self.object, self.direction)
			end
			self.amount = self.amount - 1
		end

		return (self.object.walking == 0 and self.amount == 0)
	end;
}


-- Show conversations within a sequence

ActionConversation = Action:subclass
{
	name = "ActionConversation";

	init = function(self, conversation)
		self.conversation = conversation
		self.started = false
	end;

	exec = function(self)
		if (not self.started) then
			write_conversation(self.conversation)
			self.started = true
		end
		return (ConvBox.state == CB_CLOSED and self.started)
	end;
}


-- Toggle exclusive mode on and off

exModeArray = {}

ActionExModeOn = Action:subclass
{
	name = "ActionExModeOn";

	exec = function(self)
		table.insert(exModeArray, m_get_ex_mode())
		m_set_ex_mode(1)
		--m_message("Exclusive mode turned on (".. table.getn(exModeArray) ..")")
		return true
	end;
}

ActionExModeOff = Action:subclass
{
	name = "ActionExModeOff";

	exec = function(self)
		if (table.getn(exModeArray) > 0) then
			m_set_ex_mode(exModeArray[table.getn(exModeArray)])
			table.remove(exModeArray, table.getn(exModeArray))
			--m_message("Exclusive mode turned off (".. table.getn(exModeArray) ..")")
		end
		return true
	end;
}


-- Change to another map

ActionChangeMap = Action:subclass
{
	name = "ActionChangeMap";
	
	init = function(self, filename)
		self.filename = filename
	end;

	exec = function(self)
		m_load_map(self.filename)
		return true
	end;
}


-- Fading in and out

map_fade = {alpha = 0}

ActionFadeInMap = ActionTweenVariable:subclass
{
	name = "ActionFadeInMap";
	init = function(self, time)
		ActionTweenVariable.init(self, map_fade, "alpha", time, 0, 255)
	end;
}

ActionFadeOutMap = ActionTweenVariable:subclass
{
	name = "ActionFadeOutMap";
	init = function(self, time)
		ActionTweenVariable.init(self, map_fade, "alpha", time, 255, 0)
	end;
}


-- Change the position and orientation of an object

ActionSetPosition = Action:subclass
{
	name = "ActionSetPosition";

	init = function(self, obj, x, y, dir)
		self.x = x
		self.y = y
		self.dir = dir
		self.obj = obj
	end;

	exec = function(self)
		self.obj.x = self.x
		self.obj.y = self.y

		if self.dir ~= nil then
			self.obj.dir = self.dir
		end

		return true
	end;
}


-- ==========================================================================
-- Playing music

ActionPlaySong = Action:subclass
{
	name = "ActionPlaySong";
	
	init = function(self, filename, fadeTime, wait)
		self.filename = filename
		self.fadeTime = fadeTime or 0
		self.wait = not (wait == nil or wait == 0)
		self.playingStarted = false
	end;

	exec = function(self)
		if (not self.playingStarted) then
			MusicControl:fade_to_song(self.filename, self.fadeTime)
			self.playingStarted = true
		end
		return (MusicControl.state == MC_NORMAL or (not self.wait))
	end;
}


ActionFadeOutMusic = Action:subclass
{
	name = "ActionFadeOutMusic";

	init = function(self, fadeTime, wait)
		self.fadeTime = fadeTime
		self.wait = not (wait == nil or wait == 0)
		self.fadingStarted = false
	end;

	exec = function(self)
		if (not self.fadingStarted) then
			MusicControl:fade_out(self.fadeTime)
			self.fadingStarted = true
		end
		return (MusicControl.state == MC_NORMAL or (not self.wait))
	end;
}


ActionFadeInMusic = Action:subclass
{
	name = "ActionFadeInMusic";

	init = function(self, filename, fadeTime, wait)
		self.filename = filename
		self.fadeTime = fadeTime
		self.wait = not (wait == nil or wait == 0)
		self.fadingStarted = false
	end;

	exec = function(self)
		if (not self.fadingStarted) then
			MusicControl:fade_in(self.filename, self.fadeTime)
			self.fadingStarted = true
		end
		return (MusicControl.state == MC_NORMAL or (not self.wait))
	end;
}



-- Setting states for objects that use states

ActionSetState = Action:subclass
{
	name = "ActionSetState";

	init = function(self, obj, state)
		self.state = state
		self.obj = obj
	end;

	exec = function(self)
		if (self.obj.setState) then self.obj:setState(self.state)
		else self.obj.state = self.state end
		return true
	end;
}


-- Destroy a certain object

ActionDestroyObject = Action:subclass
{
	name = "ActionDestroyObject";

	init = function(self, obj)
		self.obj = obj
		if (not self.obj) then
			m_message("Error: ActionDestroyObject: no valid object given!")
		end
	end;

	exec = function(self)
		m_destroy_object(self.obj)
		return true
	end;
}


-- Add an object

ActionAddObject = Action:subclass
{
	name = "ActionAddObject";

	init = function(self, name, x, y)
		self.objname = name
		self.x = x
		self.y = y
	end;

	exec = function(self)
		if (type(self.objname) == "string") then
			m_add_object(self.x, self.y, self.objname)
		else
			spawn(self.x, self.y, self.objname)
		end
		return true
	end;
}


-- Quit the game

ActionQuitGame = Action:subclass
{
	name = "ActionQuitGame";
	
	exec = function(self)
		m_quit_game()
		return true
	end;
}


-- Show map name

show_map_seq = nil

ActionShowMapName = Action:subclass
{
	name = "ActionShowMapName";

	init = function(self, bitmap)
		self.bitmap = bitmap
	end;

	exec = function(self)
		-- Make sure no other ActionShowMapName sequence is taking place
		ActionController:removeSequence(show_map_seq)

		-- Start a new
		show_map_seq = ActionController:addSequence{
			ActionWait(50),
			ActionSetVariable(HUD, "map_name", self.bitmap),
			ActionTweenVariable(HUD, "map_name_alpha", 100, 255, 0),
			ActionWait(200),
			ActionTweenVariable(HUD, "map_name_alpha", 100, 0, 255),
		}

		return true
	end;
}
