--
-- Here are defined the most simple and generic actions that
-- could be used in a sequence. Feel free to define more specific
-- actions for your own sequences.
--
-- All actions have an exec() function that will be called every
-- game tick until it has returned true.
--
-- A summaration of the available action types follows:
--
--   ActionSequence(sequence)
--   ActionParallel(sequence)
--   ActionAddSequence(sequence)
--   ActionCallFunction(f, ...)
--   ActionSetVariable(table, key, value)
--   ActionTweenVariable(table, key, time, to [, from, func])
--   ActionWait(duration)
--
--   ActionChangeBitmap(actor, bitmap)
--   ActionChangeDirection(actor, new_direction)
--   ActionWalk(actor, direction, amount [,col])
--   ActionWalkPath(actor, path [,col])
--   ActionConversation(conversation)
--   ActionExModeOn()
--   ActionExModeOff()
--   ActionPlaySong(filename, fadeTime [, wait])
--   ActionPlaySample(filename)
--   ActionFadeOutMusic(fadeTime [, wait])
--   ActionFadeInMusic(filename, fadeTime [, wait])
--   ActionFadeInMap(time)
--   ActionFadeOutMap(time)
--   ActionSetState(object, state)
--   ActionSetPosition(actor, x, y [,dir[,map]])
--   ActionDestroyObject(object)
--   ActionAddObject({name|class}, x, y)
--   ActionQuitGame()
--   ActionShowMapName(bitmap)
--   ActionSetCameraTarget(target [, tween])
--
-- By Bjorn Lindeijer


import("Object.lua")


Action = Object:subclass
{
	name = "Action";

	-- The init function is generally used to store the arguments.
	init = function(self) end;

	-- The exec function will be called every game tick until it returns true.
	exec = function(self) return true; end;
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

ActionParallel = Action:subclass
{
	name = "ActionParallel";

	init = function(self, actions)
		m_message("ActionParallel initializing with ".. table.getn(actions) .." actions.")
		self.actions = {}

		-- Add all actions to the list of actions to execute.
		local i
		for i = 1, table.getn(actions) do
			if (actions[i] and actions[i]:instanceOf(Action)) then
				-- Create an action execution environment for this action
				local execEnv = {}
				setmetatable(execEnv, {__index = actions[i]})

				-- Insert the action execution environment in the actions array
				table.insert(self.actions, execEnv)
			else
				m_message("ActionParallel: action not an instance of Action (".. actions[i].name ..")")
			end
		end
	end;

	exec = function(self)
		local i

		-- Execute all running actions
		for i = 1, table.getn(self.actions) do
			if (i <= table.getn(self.actions) and self.actions[i]:exec()) then
				m_message("ActionParallel finished executing "..self.actions[i].name)
				table.remove(self.actions, i)
				i = i - 1
			end
		end

		return table.getn(self.actions) == 0
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
		ActionController:addSequence(self.sequence)
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
		self.f(unpack(self.arg))
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

	init = function(self, table, key, time, to, from, func)
		self.table = table
		self.key = key
		self.time = time
		self.to = to
		if (type(from) == "number")   then self.from = from end
		if (type(from) == "function") then self.func = from end
		if (type(func) == "function") then self.func = func end
		if (not self.func) then
			self.func = function(from, to, perc)
				return from + perc * (to - from)
			end
		end

		self.count = 0
	end;
	
	exec = function(self)
		if (not self.from) then self.from = self.table[self.key] end
		if (not self.from) then return true end
		
		self.count = self.count + 1
		if (self.count <= self.time) then
			self.table[self.key] = self.func(self.from, self.to, (self.count / self.time))
		else
			self.table[self.key] = self.func(self.from, self.to, 1)
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
		self.col = col
		if (col == 0) then self.col = false end
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


-- Order characters around using a path string

ActionWalkPath = ActionSequence:subclass
{
	name = "ActionWalkPath";

	init = function(self, object, path, col)
		if (type(object) ~= "table") then error("Invalid object passed to ActionWalkPath") end
		if (type(path)  ~= "string") then error("Invalid string passed to ActionWalkPath") end

		self.actions = {}

		for w in string.gfind(path, "[UDLR]%d*") do
			local dir = string.sub(w,1,1)
			if (dir == "U") then dir = DIR_UP    end
			if (dir == "R") then dir = DIR_RIGHT end
			if (dir == "D") then dir = DIR_DOWN  end
			if (dir == "L") then dir = DIR_LEFT  end

			local amount = tonumber(string.sub(w,2))
			if (not amount or amount == 0) then amount = 1 end

			table.insert(self.actions, ActionWalk(object, dir, amount, col))
		end

		self.i = 1
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
		return (convBox.state == CB_CLOSED and self.started)
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
		else
			m_set_ex_mode(0)
		end
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

	init = function(self, obj, x, y, dir, map)
		self.x = x
		self.y = y
		self.dir = dir
		self.obj = obj
		self.map = map
	end;

	exec = function(self)
		self.obj:setPosition(self.x, self.y)

		if (self.dir) then
			self.obj.dir = self.dir
			if (self.map) then
				self.obj:setMap(self.map)
			end
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

ActionPlaySample = ActionCallFunction:subclass
{
	name = "ActionPlaySample";

	init = function(self, filename)
		if (not filename) then
			error("Error: ActionPlaySample created without a filename")
		end
		ActionCallFunction.init(self, m_play_sample, filename)
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
			Actor:spawn(self.objname, self.x, self.y)
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
		if (not bitmap) then
			self:log("Warning: no valid bitmap for showing map name!")
		end
		self.bitmap = bitmap
	end;

	exec = function(self)
		--[[
		local mapInt = BBRpgMapname()

		mapInt.bitmap = self.bitmap

		show_map_seq = ActionController:addSequence{
			ActionCallFunction(interactionMaster.addInteraction, interactionMaster, mapInt),
			ActionTweenVariable(mapInt, "perc", 50, 1, 0),
			ActionWait(100),
			ActionTweenVariable(mapInt, "perc", 50, 0, 1),
			ActionCallFunction(interactionMaster.removeInteraction, interactionMaster, mapInt),
		}
]]

		return true
	end;
}


ActionSetCameraTarget = Action:subclass
{
	name = "ActionSetCameraTarget";

	init = function(self, target, tween)
		self.target = target
		self.tween = tween
	end;

	exec = function(self)
		gameCameraTarget:setTarget(self.target, self.tween)
		return true
	end;
}
