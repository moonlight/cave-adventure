-- player_sequences.lua
-- Here we define some player sequences.
-- By Georg Muntingh

Buiten_Naar_Bos = {}
Bos_Naar_Buiten = {}
Buiten_Naar_Tent1 = {}
Buiten_Naar_Tent2 = {}
Tent1_Naar_Buiten = {}
Tent2_Naar_Buiten = {}
Cave1_Naar_Cave2 = {}
Cave2_Naar_Cave1 = {}

function Buiten_Naar_Bos:event_stand_on(obj)
	local player = m_get_player()
	if obj ~= player or m_get_ex_mode() == 1 then return end

	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionWalk(player, DIR_RIGHT, 2),
		ActionChangeMap("data/maps/bos.map"),
		ActionSetPosition(player, -1, player.y + 6, DIR_RIGHT),
		ActionAddSequence({
			ActionWalk(player, DIR_RIGHT, 3),
			ActionExModeOff(),
		}),
		ActionFadeInMusic("data/music/KR-UT2003-Menu.ogg", 50, 0),
		ActionFadeInMap(50),
	})

	SeqControl:add_sequence({
		ActionFadeOutMusic(50, 0),
		ActionFadeOutMap(50),
	})
end

function Bos_Naar_Buiten:event_stand_on(obj)
	local player = m_get_player()

	if obj ~= player or m_get_ex_mode() == 1 then return end

	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionWalk(player, DIR_LEFT, 2),
		ActionChangeMap("data/maps/buiten.map"),
		ActionSetPosition(player, 85, player.y - 6, DIR_LEFT),
		ActionAddSequence({
			ActionWalk(player, DIR_LEFT, 3),
			ActionExModeOff(),
		}),
		ActionFadeInMusic("data/music/KR-UT2003-Menu.ogg", 50, 0),
		ActionFadeInMap(50),
	})

	SeqControl:add_sequence({
		ActionFadeOutMusic(50, 0),
		ActionFadeOutMap(50),
	})
end

function Buiten_Naar_Tent1:event_activate(instigator)
	local player = m_get_player()
	if instigator ~= player or player.dir ~= DIR_UP then return end

	local text_table = {
		{{"Frode", "A small tent for Georg and Laurens"}},
		{{"Frode", "It's a mess inside."}},
	}

	repeat n = random(getn(text_table)) until (n ~= self.prev_random)
	self.prev_random = n
		
	SeqControl:add_sequence({
		ActionFadeOutMap(50),
		ActionChangeMap("data/maps/tent1.map"),
		ActionSetPosition(player, 7, 9, DIR_UP),
		ActionFadeInMap(50),
		ActionConversation(text_table[n]),
	})
end

function Buiten_Naar_Tent2:event_activate(instigator)
	local player = m_get_player()
	if instigator ~= player or player.dir ~= DIR_UP then return end
	
	local text_table = {
		{{"Frode", "Small tent for Chris and Margje"}},
		{{"Frode", "It's a terrible mess inside."}},
	}

	repeat n = random(getn(text_table)) until (n ~= self.prev_random)
	self.prev_random = n

	SeqControl:add_sequence({
		ActionFadeOutMap(50),
		ActionChangeMap("data/maps/tent1.map"),
		ActionSetPosition(player, 21, 10, DIR_UP),
		ActionFadeInMap(50),
		ActionConversation(text_table[n]),
	})
end

function Tent1_Naar_Buiten:event_stand_on(instigator)
	local player = m_get_player()
	if instigator ~= player then return end

	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionFadeOutMap(50),
		ActionChangeMap("data/maps/buiten.map"),
		ActionSetPosition(player, 28, 21, DIR_DOWN),
		ActionFadeInMap(50),
		ActionExModeOff(),
	})
end

function Tent2_Naar_Buiten:event_stand_on(instigator)
	local player = m_get_player()
	if instigator ~= player then return end

	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionFadeOutMap(50),
		ActionChangeMap("data/maps/buiten.map"),
		ActionSetPosition(player, 22, 21, DIR_DOWN),
		ActionFadeInMap(50),
		ActionExModeOff(),
	})
end

function Cave1_Naar_Cave2:event_stand_on(obj)
	local player = m_get_player()
	if obj ~= player or m_get_ex_mode() == 1 then return end

	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionWalk(player, DIR_LEFT, 2),
		ActionChangeMap("data/maps/cave2.map"),
		ActionSetPosition(player, 64, player.y + 57, DIR_LEFT),
		ActionAddSequence({
			ActionWalk(player, DIR_LEFT, 3),
			ActionExModeOff(),
		}),
		ActionFadeInMap(50),
	})

	SeqControl:add_sequence({
		ActionFadeOutMap(50),
	})
end

function Cave2_Naar_Cave1:event_stand_on(obj)
	local player = m_get_player()
	if obj ~= player or m_get_ex_mode() == 1 then return end

	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionWalk(player, DIR_RIGHT, 2),
		ActionChangeMap("data/maps/cave1.map"),
		ActionSetPosition(player, 0, player.y - 57, DIR_RIGHT),
		ActionAddSequence({
			ActionWalk(player, DIR_RIGHT, 3),
			ActionExModeOff(),
		}),
		ActionFadeInMap(50),
	})

	SeqControl:add_sequence({
		ActionFadeOutMap(50),
	})
end
