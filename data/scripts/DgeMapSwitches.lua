--
-- Here we define some player sequences.
-- By Georg Muntingh


Buiten_Naar_Bos = {}

function Buiten_Naar_Bos:event_stand_on(obj)
	local player = m_get_player()
	if obj ~= player or m_get_ex_mode() == 1 then return end

	ActionController:addSequence({
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

	ActionController:addSequence({
		ActionFadeOutMusic(50, 0),
		ActionFadeOutMap(50),
	})
end

Bos_Naar_Buiten = {}

function Bos_Naar_Buiten:event_stand_on(obj)
	local player = m_get_player()

	if obj ~= player or m_get_ex_mode() == 1 then return end

	ActionController:addSequence({
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

	ActionController:addSequence({
		ActionFadeOutMusic(50, 0),
		ActionFadeOutMap(50),
	})
end

Buiten_Naar_Tent1 = {}

function Buiten_Naar_Tent1:activatedBy(instigator)
	local player = m_get_player()
	if instigator ~= player or player.dir ~= DIR_UP then return end

	local text_table = {
		{{"Frode", "A small tent for Georg and Laurens"}},
		{{"Frode", "It's a mess inside."}},
	}

	repeat n = math.random(table.getn(text_table)) until (n ~= self.prev_random)
	self.prev_random = n
		
	ActionController:addSequence({
		ActionFadeOutMap(50),
		ActionChangeMap("data/maps/tent1.map"),
		ActionSetPosition(player, 7, 9, DIR_UP),
		ActionFadeInMap(50),
		ActionConversation(text_table[n]),
	})
end

Buiten_Naar_Tent2 = {}

function Buiten_Naar_Tent2:activatedBy(instigator)
	local player = m_get_player()
	if instigator ~= player or player.dir ~= DIR_UP then return end
	
	local text_table = {
		{{"Frode", "Small tent for Chris and Margje"}},
		{{"Frode", "It's a terrible mess inside."}},
	}

	repeat n = math.random(table.getn(text_table)) until (n ~= self.prev_random)
	self.prev_random = n

	ActionController:addSequence({
		ActionFadeOutMap(50),
		ActionChangeMap("data/maps/tent1.map"),
		ActionSetPosition(player, 21, 10, DIR_UP),
		ActionFadeInMap(50),
		ActionConversation(text_table[n]),
	})
end

Tent1_Naar_Buiten = {}

function Tent1_Naar_Buiten:event_stand_on(instigator)
	local player = m_get_player()
	if instigator ~= player then return end

	ActionController:addSequence({
		ActionExModeOn(),
		ActionFadeOutMap(50),
		ActionChangeMap("data/maps/buiten.map"),
		ActionSetPosition(player, 28, 21, DIR_DOWN),
		ActionFadeInMap(50),
		ActionExModeOff(),
	})
end

Tent2_Naar_Buiten = {}

function Tent2_Naar_Buiten:event_stand_on(instigator)
	local player = m_get_player()
	if instigator ~= player then return end

	ActionController:addSequence({
		ActionExModeOn(),
		ActionFadeOutMap(50),
		ActionChangeMap("data/maps/buiten.map"),
		ActionSetPosition(player, 22, 21, DIR_DOWN),
		ActionFadeInMap(50),
		ActionExModeOff(),
	})
end


Cave1_Naar_Cave2 = Actor:subclass
{
	name = "Cave1_Naar_Cave2";

	event_stand_on = function(self, obj)
		local player = m_get_player()
		if obj ~= player or m_get_ex_mode() == 1 then return end

		ActionController:addSequence({
			ActionExModeOn(),
			ActionAddSequence({
				ActionWalk(player, DIR_LEFT, 1),
			}),
			ActionFadeOutMap(50),
			ActionChangeMap("data/maps/cave2.map"),
			ActionShowMapName(m_get_bitmap("cave_title_2.bmp")),
			ActionSetPosition(player, 64, player.y + 57, DIR_LEFT),
			ActionAddSequence({
				ActionWalk(player, DIR_LEFT, 2),
				ActionExModeOff(),
			}),
			ActionFadeInMap(50),
		})
	end;
}


Cave2_Naar_Cave1 = Actor:subclass
{
	name = "Cave2_Naar_Cave1";

	event_stand_on = function(self, obj)
		local player = m_get_player()
		if obj ~= player or m_get_ex_mode() == 1 then return end

		ActionController:addSequence({
			ActionExModeOn(),
			ActionAddSequence({
				ActionWalk(player, DIR_RIGHT, 1),
			}),
			ActionFadeOutMap(50),
			ActionChangeMap("data/maps/cave1.map"),
			ActionShowMapName(m_get_bitmap("cave_title_1.bmp")),
			ActionSetPosition(player, -1, player.y - 57, DIR_RIGHT),
			ActionAddSequence({
				ActionWalk(player, DIR_RIGHT, 2),
				ActionExModeOff(),
			}),
			ActionFadeInMap(50),
		})
	end;
}
