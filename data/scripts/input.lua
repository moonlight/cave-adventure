-- input.lua
-- Handles player keypresses
--


-- (Player) character states
CHR_ATTACK = 1
CHR_HIT    = 2
CHR_READY  = 3
CHR_DEAD   = 4


function event_keypress(key)
	--m_message(key.." key has been pressed!")
	if (key == "action") then
		if (show_main_menu and not started) then
			started = 1
			ActionController:addSequence({
				ActionFadeOutMap(50),
				ActionSetVariable(_G, "show_main_menu", nil),
				ActionChangeMap("data/maps/cave1.map"),
				ActionSetPosition(m_get_player(), 50, 4, DIR_DOWN), -- Normal start position in cave 1
				--ActionSetPosition(m_get_player(), 25, 15, DIR_UP), -- Just before sequence in cave 2
				--ActionSetPosition(m_get_player(), 35, 19, DIR_UP), -- Just before starting boss fight in cave 3
				--ActionSetPosition(m_get_player(), 4, 5, DIR_LEFT), -- Near cave 1 exit to cave 2
				ActionPlaySong("data/music/Cave.ogg", 100),
				ActionFadeInMap(100),
				--ActionConversation(conv.INTRO),
				ActionExModeOff(),
				ActionShowMapName(m_get_bitmap("cave_title_1.bmp"))
			})
		else
			ConvBox:keypress()
		end
	end

	--CombatControl:keypress(key)
	if (key == "attack") then
		local player = m_get_player()
		player:attack()
	end
end
