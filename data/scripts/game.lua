-- game.lua
-- This file defines some global functions for the game.
-- By Bjørn Lindeijer


game = {
	game_over = 0,
	game_over_alpha = 0,
}

camera = {
	target = nil,
}


--
-- This function is called once, when the game is initialized.
--
function event_init()
	-- Load tile bitmaps
	--m_import_tile_bmp("buiten.bmp", 24, 24, 0)
	--m_import_tile_bmp("tuin.bmp", 24, 24, 0)
	m_import_tile_bmp("cave.bmp", 24, 24, 0)

	-- Add animations
	add_animations()

	-- Initialize stuff
	ConvBox:init()
	HUD:initialize()
	MusicControl:init()
	CombatControl:init()
	GUI:init()

	-- Show startup screen
	show_main_menu = 1
	main_menu_bg = {
		bm = m_get_bitmap("menu.bmp"),
		alpha = 0,
	}
	main_title = {
		bm = m_get_bitmap("cave.tga"),
		y = -50,
	}
	main_start = {
		bm = m_get_bitmap("start.tga"),
		y = 300,
	}
	SeqControl:add_sequence({
		ActionExModeOn(),
		ActionTweenVariable(main_menu_bg, "alpha", 200, 255),
		ActionTweenVariable(main_title, "y", 200, 184),
		ActionTweenVariable(main_start, "y", 100, 220),
	})


	-- Spawn the player
	player = m_add_object(-1, -1, "Player")
	m_set_player(player)

	camera.target = player
	camera_handle = m_add_object(0, 0, "CameraHandle")
	camera_handle.travel = 1

	-- Starting position
	--m_load_map("data/maps/cave1.map")
	--player.x = 50
	--player.y = 4
	--player.dir = DIR_DOWN

	-- Going inside prison position
	--m_load_map("data/maps/cave2.map")
	--player.x = 25
	--player.y = 13
	--player.dir = DIR_UP

	-- Boss position
	--m_load_map("data/maps/cave3.map")
	--player.x = 35
	--player.y = 18
	--player.dir = DIR_UP

	--MusicControl:play_song("data/music/KR-UT2003-Menu.ogg")
end

--
-- This function is called whenever a switch to another map takes place.
--
function event_load_map(map_name)
	m_message("event_load_map received argument: \""..map_name.."\"");
	if (map_name == "data/maps/buiten.map") then prepare_buiten() end
	if (map_name == "data/maps/tent1.map") then prepare_tent() end
	if (map_name == "data/maps/bos.map") then prepare_bos() end
	if (map_name == "data/maps/cave1.map") then prepare_cave1() end
	if (map_name == "data/maps/cave2.map") then prepare_cave2() end
	if (map_name == "data/maps/cave3.map") then prepare_cave3() end
end


--
-- This function is called every game update, right before all objects get
-- updated.
--
function event_logic_update()
	HUD:logic_update()
	ConvBox:update()
	SeqControl:update()
	MusicControl:update()
	--CombatControl:update()
end


--
-- This function is called right after the map and objects have been rendered
-- by the engine. It is meant to draw stuff on the screen that is not actually
-- present on the map, like text boxes and info displays.
--
-- Here's a general set of functions that can be used for positioning and
-- drawing on the screen. The draw functions should generally only be used
-- within this function call.
--
--   function m_get_cursor()        // returns x, y
--   function m_set_cursor(x, y)
--   function m_text_size(text)     // returns width, height
--   function m_bitmap_size(bitmap) // returns width, height
--   function m_screen_size()       // returns width, height
--   function m_draw_text(text)
--   function m_draw_bitmap(bitmap, dest_w, dest_h, src_x, src_y, src_w, src_h)
--   function m_draw_viewport(x, y, w, h, target)
--
function event_render()
	local width, height = m_screen_size()

	if (show_main_menu) then
		m_set_cursor(0,0)
		m_set_alpha(main_menu_bg.alpha)
		draw_icon(main_menu_bg.bm)
		m_set_alpha(255)
		m_set_drawmode(DM_ALPHA)
		m_set_cursor(10,main_title.y); draw_icon(main_title.bm)
		m_set_cursor(82,main_start.y); draw_icon(main_start.bm)
		m_set_drawmode(DM_MASKED)
	else
		m_draw_viewport((width - 320) * 0.5, (height - 240) * 0.5, 320, 240, camera.target)
		--m_draw_viewport(width / 4, height / 4, width / 2, height / 2, m_get_player())
	end

	if (map_fade ~= nil and map_fade.alpha ~= nil and map_fade.alpha > 0) then
		local w,h = m_screen_size()
		m_set_alpha(map_fade.alpha)
		m_set_cursor(0,0)
		draw_rect(m_get_bitmap("pixel_black.bmp"), w, h)
		m_set_alpha(255)
	end

	if (not show_main_menu) then
		HUD:draw()
		ConvBox:draw()
		--CombatControl:draw()
	end
end


--
-- A helper function used by scripts that want to show a conversation.
--
function write_conversation(data)
	local conversation = {}

	for index, value in data do
		table.insert(conversation, value[1]..": \""..value[2].."\"")
	end

	Dialog:do_dialog_sequence(conversation)
end

--
-- Another helper function to make it easier to choose a math.random thing to say, unequal
-- to what was said last time.
--
function get_new_n(old_n, max_n)
	local n
	if (max_n > 1) then
		repeat n = math.random(max_n) until (n ~= old_n)
	else n = max_n end
	return n
end
