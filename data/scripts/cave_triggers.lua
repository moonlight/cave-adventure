-- cave_triggers.lua
-- Cave-specified triggers
-- By Georg Muntingh

CaveFallingAsleep = {}
CaveNoticeStrong = {}

function CaveFallingAsleep:event_init()
end

function CaveFallingAsleep:event_stand_on(instigator)
	local player = m_get_player()

	if (instigator ~= m_get_player()) then
		instigator:take_damage(100)
		return
	end
	SeqControl:add_sequence({
		ActionConversation(conv.YAWN_TIRED),
		ActionExModeOn(),
		ActionWalk(player, DIR_LEFT, 6),
		ActionWalk(player, DIR_DOWN, 1),
		ActionWalk(player, DIR_LEFT, 1),
		ActionChangeDirection(player, DIR_DOWN),
		ActionWait(25),
		ActionConversation(conv.QUIET_CORNER),
		ActionWait(25),
		ActionSetVariable(m_get_player(), "tick_time", 0), -- DISABLELNG PLAYER TICK!
		ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit1.tga")),
		ActionWait(25),
		ActionConversation(conv.REALLY_TIRED),
		ActionWait(25),
		ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit2.tga")),
		ActionWait(100),
		ActionFadeOutMap(50),
		ActionWait(50),
		ActionFadeInMap(50),
		ActionWalk(caveman1, DIR_DOWN, 5),
		ActionChangeDirection(caveman1, DIR_LEFT),
		ActionWait(50),
		ActionSetVariable(caveman1, "speed", 5.4),
		ActionWalk(caveman1, DIR_LEFT, 3),
		ActionWait(50),
		ActionConversation(conv.DISCOVER_HUMAN),
		ActionAddSequence({
			ActionWalk(caveman1, DIR_RIGHT, 3),
		}),
		ActionFadeOutMap(56),
		ActionChangeMap("data/maps/cave3.map"),
		ActionSetVariable(globals(), "camera_target", caveman1),
		ActionSetPosition(caveman1, 35, 16, DIR_UP),
		ActionAddSequence({
			ActionFadeInMap(50),
		}),
		ActionWalk(caveman1, DIR_UP, 3),
		ActionConversation(conv.INFORM_KING),
		ActionAddSequence({
			ActionFadeOutMap(56),
		}),
		ActionWalk(caveman1, DIR_DOWN, 3),
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
		ActionConversation(conv.KICK_FIRST),
		ActionWait(50),
		ActionSetVariable(caveman1,"attacking", 1),
		ActionCallFunction(SpawnSparkyHit, 18, 10, player.offset_x, player.offset_y, player.offset_z + 24),
		ActionSetVariable(caveman1,"attacking", 0),
		ActionConversation(conv.BRING_TO_KING),
		ActionFadeOutMap(50),
		ActionSetPosition(camera_handle, 35, 12),
		ActionSetVariable(globals(), "camera_target", camera_handle),
		ActionChangeMap("data/maps/cave3.map"),
		ActionSetPosition(caveman1, 34, 13, DIR_UP),
		ActionSetPosition(m_get_player(), 35, 13),
		ActionSetPosition(caveman2, 36, 13, DIR_UP),
		ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit2.tga")),
		ActionFadeInMap(50),
		ActionConversation(conv.BROUGHT_HUMAN),
		ActionFadeOutMap(50),
		ActionWait(50),
		ActionSetVariable(globals(), "camera_target", m_get_player()),
		ActionSetPosition(m_get_player(), 80, 20),
		ActionFadeInMap(50),
		ActionWait(50),
		ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit1.tga")),
		ActionWait(50),
		ActionSetVariable(m_get_player(), "tick_time", 1), -- ENABLEING PLAYER TICK!
		ActionChangeDirection(m_get_player(), DIR_DOWN),
		ActionConversation(conv.WHAT_THE),
		ActionWalk(m_get_player(), DIR_RIGHT, 2),
		ActionWalk(m_get_player(), DIR_DOWN, 4),
		ActionConversation(conv.WHAT_HAPPENED),

		-- Prepare caveman for next sequence (when escaping from prison)
		ActionSetPosition(caveman1, 67, 34, DIR_DOWN),
		ActionSetPosition(caveman2, 69, 34, DIR_DOWN),

		ActionExModeOff(),
	})
end




function CaveNoticeStrong:event_init()
end

function CaveNoticeStrong:event_stand_on(instigator)
	if (instigator ~= m_get_player()) then
		instigator:take_damage(100)
		return
	end
	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionDestroyObject(self),
		ActionWait(50),
		ActionChangeDirection(caveman1, DIR_RIGHT),
		ActionChangeDirection(caveman2, DIR_LEFT),
		ActionWait(50),
		ActionChangeDirection(m_get_player(), DIR_LEFT),
		ActionConversation(conv.WOW_ESCAPED),
		ActionChangeDirection(m_get_player(), DIR_RIGHT),
		ActionConversation(conv.MUST_BE_STRONG),
		ActionWait(50),
		ActionChangeDirection(m_get_player(), DIR_DOWN),
		ActionWait(100),
		ActionConversation(conv.KING_IS_SLAVEDRIVER),
		ActionChangeDirection(caveman1, DIR_DOWN),
		ActionChangeDirection(caveman2, DIR_DOWN),
		ActionExModeOff(),
	})
end
