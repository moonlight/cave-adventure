-- seq_actions.lua
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
--   ActionWait(duration)
--   ActionChangeBitmap(object, bitmap)
--   ActionChangeDirection(object, new_direction)
--   ActionWalk(object, direction, amount [,col])
--   ActionConversation(conversation)
--   ActionExModeOn()
--   ActionExModeOff()
--   ActionPlaySong(filename, fadeTime [, wait])
--   ActionFadeOutMusic(fadeTime [, wait])
--   ActionFadeInMusic(filename, fadeTime [, wait])
--   ActionFadeInMap(time)
--   ActionFadeOutMap(time)
--   ActionSetState(obj, state)
--   ActionSetPosition(obj, x, y [, dir])
--   ActionSetVariable(obj, variable_name, value)
--   ActionChangeMap(filename)
--   ActionAddSequence(sequence)
--   ActionTweenVariable(obj, variable_name, time, to [, from])
--   ActionDestroyObject(obj)
--   ActionAddObject(name, x, y)
--   ActionQuitGame()
--
-- By Bjørn Lindeijer

-- Call a function during a function

function ActionCallFunction(f, ...)
	me = {}

	me.name = "CallFunction"
	me.f = f
	me.arg = arg

	function me:finished()
		if (getn(self.arg) == 0) then self.f() end
		if (getn(self.arg) == 1) then self.f(self.arg[1]) end
		if (getn(self.arg) == 2) then self.f(self.arg[1], self.arg[2]) end
		if (getn(self.arg) == 3) then self.f(self.arg[1], self.arg[2], self.arg[3]) end
		if (getn(self.arg) == 4) then self.f(self.arg[1], self.arg[2], self.arg[3], self.arg[4]) end
		if (getn(self.arg) == 5) then self.f(self.arg[1], self.arg[2], self.arg[3], self.arg[4], self.arg[5]) end
		return 1
	end

	return me
end

-- Pause a sequence for <duration> game ticks

function ActionWait(duration)
	me = {}
	
	me.name = "Wait"
	me.timer = 0
	me.duration = duration

	function me:exec()
		self.timer = self.timer + 1
	end

	function me:finished()
		return (self.timer >= self.duration)
	end

	return me
end


-- Instantly change the bitmap of a single object

function ActionChangeBitmap(object, bitmap)
	me = {}
	
	me.name = "ChangeBitmap"
	me.object = object
	me.bitmap = bitmap

	function me:finished()
		self.object.bitmap = self.bitmap
		return 1
	end

	return me
end


-- Instantly change the direction of a single object

function ActionChangeDirection(object, direction)
	me = {}

	me.name = "ActionChangeDirection"
	me.object = object
	me.direction = direction

	function me:finished()
		self.object.dir = self.direction
		return 1
	end

	return me
end


-- Order characters around.

function ActionWalk(object, direction, amount, col)
	me = {}

	me.name = "Walk"
	me.object = object
	me.direction = direction
	me.amount = amount
	me.col = (col ~= nil and col ~= 0)

	function me:exec()
		if (self.object.walking == 0 and self.amount > 0) then
			if (self.col) then
				m_walk_obj(self.object, self.direction)
			else
				m_walk_obj_nocol(self.object, self.direction)
			end
			self.amount = self.amount - 1
		end
	end

	function me:finished()
		return (self.object.walking == 0 and self.amount == 0)
	end

	return me
end


-- Show conversations within a sequence

function ActionConversation(conversation)
	me = {}

	me.name = "Conversation"
	me.conv_started = 0
	me.conversation = conversation

	function me:exec()
		if (self.conv_started == 0) then
			m_message("Starting scripted conversation.")
			write_conversation(self.conversation)
			self.conv_started = 1
		end
	end

	function me:finished()
		return (ConvBox.state == CB_CLOSED and self.conv_started == 1)
	end

	return me
end


-- Toggle exclusive mode on and off

exModeArray = {}

function ActionExModeOn()
	local me = {}
	me.name = "ExModeOn"
	function me:finished()
		tinsert(exModeArray, m_get_ex_mode())
		m_set_ex_mode(1)
		m_message("Exclusive mode turned on (".. getn(exModeArray) ..")")
		return 1
	end
	return me
end

function ActionExModeOff()
	local me = {}
	me.name = "ExModeOff"
	function me:finished()
		m_set_ex_mode(exModeArray[getn(exModeArray)])
		tremove(exModeArray, getn(exModeArray))
		m_message("Exclusive mode turned off (".. getn(exModeArray) ..")")
		return 1
	end
	return me
end


-- Playing music

function ActionPlaySong(filename, fadeTime, wait)
	local me = {}

	me.name = "PlaySong"
	me.filename = filename
	me.fadeTime = fadeTime
	if (me.fadeTime == nil) then me.fadeTime = 0 end
	me.wait = wait
	me.playingStarted = 0

	function me:exec()
		if (self.playingStarted == 0) then
			MusicControl:fade_to_song(self.filename, self.fadeTime)
			self.playingStarted = 1
		end
	end

	function me:finished()
		return (self.playingStarted == 1 and (MusicControl.state == MC_NORMAL or (self.wait == nil or self.wait == 0)))
	end

	return me
end

function ActionFadeOutMusic(fadeTime, wait)
	local me = {}
	me.name = "FadeOutMusic"
	me.fadeTime = fadeTime
	me.wait = wait
	me.fadingStarted = 0
	function me:exec()
		if (self.fadingStarted == 0) then
			MusicControl:fade_out(self.fadeTime)
			self.fadingStarted = 1
		end
	end
	function me:finished()
		return (self.fadingStarted == 1 and (MusicControl.state == MC_NORMAL or (self.wait == nil or self.wait == 0)))
	end
	return me
end

function ActionFadeInMusic(filename, fadeTime, wait)
	local me = {}
	me.name = "FadeInMusic"
	me.filename = filename
	me.fadeTime = fadeTime
	me.wait = wait
	me.fadingStarted = 0
	function me:exec()
		if (self.fadingStarted == 0) then
			MusicControl:fade_in(self.filename, self.fadeTime)
			self.fadingStarted = 1
		end
	end
	function me:finished()
		return (self.fadingStarted == 1 and (MusicControl.state == MC_NORMAL or (self.wait == nil or self.wait == 0)))
	end
	return me
end


-- Fading in and out

function ActionFadeInMap(time)
	return ActionTweenVariable(globals(), "map_fadeout", time, 0, 255)
end

function ActionFadeOutMap(time)
	return ActionTweenVariable(globals(), "map_fadeout", time, 255, 0)
end


-- Setting states for objects that use states

function ActionSetState(obj, state)
	me = {}
	me.name = "SetState"
	me.state = state
	me.obj = obj
	function me:finished()
		if (self.obj.setState) then self.obj:setState(self.state)
		else self.obj.state = self.state end
		return 1
	end
	return me
end



-- Instantly change the position and orientation of an object

function ActionSetPosition(obj, x, y, dir)
	me = {}

	me.name = "SetPosition"
	me.x = x
	me.y = y
	me.dir = dir
	me.obj = obj

	function me:finished()
		self.obj.x = self.x
		self.obj.y = self.y

		if self.dir ~= nil then
			self.obj.dir = self.dir
		end

		return 1
	end
	
	return me
end


-- Change to another map

function ActionChangeMap(filename)
	me = {}
	
	me.name = "ChangeMap"
	me.filename = filename

	function me:finished()
		m_load_map(self.filename)
		return 1
	end

	return me
end


-- Add a sequence to the sequence controller

function ActionAddSequence(sequence)
	me = {}
	me.name = "AddSequence"
	me.sequence = sequence
	function me:finished()
		SeqControl:add_sequence(self.sequence)
		return 1
	end
	return me
end


-- Set a specified variable of a certain object to a specific value

function ActionSetVariable(obj, varname, value)
	me = {}
	me.name = "SetVariable"
	me.obj = obj
	me.varname = varname
	me.value = value
	function me:finished()
		if (self.obj) then self.obj[self.varname] = self.value
		else m_message("ActionSetVariable: no valid object given!")
		end
		return 1
	end
	return me
end


-- Tween a specified variable of a certain object to a specific value

function ActionTweenVariable(obj, varname, time, to, from)
	me = {}
	me.name = "TweenVariable"
	me.obj = obj
	me.varname = varname
	me.time = time
	me.count = 0
	me.to = to
	me.from = from or obj[varname]

	function me:finished()
		return (self.count > self.time)
	end
	function me:exec()
		self.count = self.count + 1
		if (self.count <= self.time) then
			self.obj[self.varname] = self.from + ((self.count / self.time) * (self.to - self.from))
		else
			self.obj[self.varname] = self.to
		end
	end
	return me
end


-- Destroy a certain object

function ActionDestroyObject(obj)
	me = {}
	me.name = "DestroyObject"
	me.obj = obj
	function me:finished()
		if (self.obj) then m_destroy_object(self.obj)
		else m_message("ActionDestroyObject: no valid object given!")
		end
		return 1
	end
	return me
end

--
-- Add an object
--

function ActionAddObject(name, x, y)
	me = {}
	me.name = "AddObject"
	me.objname = name
	me.x = x
	me.y = y
	function me:finished()
		m_add_object(self.x, self.y, self.objname)
		return 1
	end
	return me
end


-- Quit the game

function ActionQuitGame(obj)
	me = {}
	me.name = "QuitGame"
	me.obj = obj
	function me:finished()
		m_quit_game()
		return 1
	end
	return me
end

