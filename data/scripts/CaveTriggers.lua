-- cave_triggers.lua
-- Cave-specified triggers
-- By Georg Muntingh


CaveFallingAsleep = Actor:subclass
{
	name = "CaveFallingAsleep";

	event_stand_on = function(self, instigator)
		local player = m_get_player()

		if (instigator ~= m_get_player()) then
			-- Some monster that wandered too far away is moving into this critical area,
			-- so get rid of him.
			instigator:take_damage(100)
			return
		end
		ActionController:addSequence({
			-- The player gets tired and is going to get some rest in a quiet corner.
			ActionConversation(lang:getConv("YAWN_TIRED")),
			ActionExModeOn(),
			ActionWalk(player, DIR_LEFT, 7),
			ActionChangeDirection(player, DIR_DOWN),
			ActionWait(25),
			ActionConversation(lang:getConv("QUIET_CORNER")),
			ActionWait(25),
			ActionSetVariable(m_get_player(), "tick_time", 0), -- DISABLELNG PLAYER TICK!
			ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit1.tga")),
			ActionWait(25),
			ActionConversation(lang:getConv("REALLY_TIRED")),
			ActionWait(25),
			ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit2.tga")),
			ActionWait(100),

			-- The player has fallen asleep, time passes...
			ActionFadeOutMap(50),
			ActionWait(50),
			ActionFadeInMap(50),

			-- Suddenly, a caveman arrives and notices the player. He runs away, to warn
			-- his leader as soon as possible.
			ActionWalk(caveman1, DIR_DOWN, 5),
			ActionChangeDirection(caveman1, DIR_LEFT),
			ActionWait(50),
			ActionSetVariable(caveman1, "speed", 5.4),
			ActionWalk(caveman1, DIR_LEFT, 3),
			ActionWait(50),
			ActionConversation(lang:getConv("DISCOVER_HUMAN")),
			ActionAddSequence({
				ActionWalk(caveman1, DIR_RIGHT, 3),
			}),
			ActionFadeOutMap(56),

			-- The caveman arrives at his leader. His leader sends him back to fetch the
			-- human straight away.
			ActionChangeMap("data/maps/cave3.map"),
			ActionSetVariable(camera, "target", caveman1),
			ActionSetVariable(caveman1, "offset_x", 0),
			ActionSetPosition(caveman1, 35, 16, DIR_UP),
			ActionAddSequence({
				ActionFadeInMap(50),
			}),
			ActionWalk(caveman1, DIR_UP, 3),
			ActionConversation(lang:getConv("INFORM_KING")),
			ActionAddSequence({
				ActionFadeOutMap(56),
			}),
			ActionWalk(caveman1, DIR_DOWN, 3),

			-- Two cavemen arrive at the player, cast a spell on him and take him back
			-- to the king
			ActionChangeMap("data/maps/cave2.map"),
			ActionSetPosition(caveman1, 24, 4, DIR_DOWN),
			ActionSetPosition(caveman2, 24, 3, DIR_DOWN),
			ActionSetVariable(caveman2, "speed", 5.4),
			ActionAddSequence({
				ActionAddSequence({
					ActionFadeInMap(50),
				}),
				ActionWalk(caveman1, DIR_DOWN, 5),
				ActionWalk(caveman1, DIR_LEFT, 5),
			}),
			ActionWalk(caveman2, DIR_DOWN, 6),
			ActionWalk(caveman2, DIR_LEFT, 4),
			ActionWait(50),
			ActionConversation(lang:getConv("KICK_FIRST")),
			ActionWait(50),
			ActionSetVariable(caveman1,"attacking", 1),
			ActionCallFunction(SpawnSparkyHit, 18, 10, player.offset_x, player.offset_y, player.offset_z + 24),
			ActionWait(40),
			ActionSetVariable(caveman1,"attacking", 0),
			ActionWait(10),
			ActionConversation(lang:getConv("BRING_TO_KING")),
			ActionFadeOutMap(50),

			-- The two cavemen and the player arrive at the king. The king tells the
			-- cavemen he wants the human in his prison.
			ActionSetPosition(camera_handle, 35, 12),
			ActionSetVariable(camera, "target", camera_handle),
			ActionChangeMap("data/maps/cave3.map"),
			ActionSetPosition(caveman1, 34, 13, DIR_UP),
			ActionSetPosition(m_get_player(), 35, 13),
			ActionSetPosition(caveman2, 36, 13, DIR_UP),
			ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit2.tga")),
			ActionFadeInMap(50),
			ActionConversation(lang:getConv("BROUGHT_HUMAN")),
			ActionFadeOutMap(50),

			-- The player finds himself locked in a prison.
			ActionWait(50),
			ActionSetVariable(camera, "target", m_get_player()),
			ActionSetPosition(m_get_player(), 80, 20),
			ActionFadeInMap(50),
			ActionWait(50),
			ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit1.tga")),
			ActionWait(50),
			ActionSetVariable(m_get_player(), "tick_time", 1), -- ENABLEING PLAYER TICK!
			ActionChangeDirection(m_get_player(), DIR_DOWN),
			ActionConversation(lang:getConv("WHAT_THE")),
			ActionWalk(m_get_player(), DIR_RIGHT, 2),
			ActionWalk(m_get_player(), DIR_DOWN, 4),
			ActionConversation(lang:getConv("WHAT_HAPPENED")),

			-- Prepare caveman for next sequence (when escaping from prison)
			ActionSetPosition(caveman1, 67, 34, DIR_DOWN),
			ActionSetPosition(caveman2, 69, 34, DIR_DOWN),

			ActionExModeOff(),
			ActionShowMapName(m_get_bitmap("cave_title_3.bmp")),
		})
	end;
}





CaveNoticeStrong = Actor:subclass
{
	name = "CaveNoticeStron";

	event_stand_on = function(self, instigator)
		if (instigator ~= m_get_player()) then
			instigator:take_damage(100)
			return
		end
		ActionController:addSequence({
			-- The player arrives at two cavemen guards. They are impressed by
			-- his escape and tell him the story about their slavedriver, asking
			-- the player to kill him.
			ActionExModeOn(),
			ActionDestroyObject(self),
			ActionWait(50),
			ActionChangeDirection(caveman1, DIR_RIGHT),
			ActionChangeDirection(caveman2, DIR_LEFT),
			ActionWait(50),
			ActionChangeDirection(m_get_player(), DIR_LEFT),
			ActionConversation(lang:getConv("WOW_ESCAPED")),
			ActionChangeDirection(m_get_player(), DIR_RIGHT),
			ActionConversation(lang:getConv("MUST_BE_STRONG")),
			ActionWait(50),
			ActionChangeDirection(m_get_player(), DIR_DOWN),
			ActionWait(100),
			ActionConversation(lang:getConv("KING_IS_SLAVEDRIVER")),
			ActionChangeDirection(caveman1, DIR_DOWN),
			ActionChangeDirection(caveman2, DIR_DOWN),
			ActionExModeOff(),
		})
	end;
}
