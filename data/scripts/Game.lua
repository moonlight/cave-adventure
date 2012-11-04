--
-- This file defines some global functions for the game.
-- By Bjorn Lindeijer

import("Object.lua")
import("ConversationWindow.lua")
import("GuiTheme.lua")


Game = Object:subclass
{
	name = "Game";

	init = function(self)
		-- Initialize stuff
		MusicControl:init()
		guiTheme = self.guiThemeClass()          -- WARNING: Bad design, introducing a global variable!
		convBox = self.conversationWindowClass() -- WARNING: I have no shame!


		if (self.textProviderClass ~= nil) then
			self.textProvider = self.textProviderClass()
		end

		local width, height = m_screen_size()
		--self.viewPort = Viewport(
		--	(width  - 320) * 0.5,
		--	(height - 240) * 0.5,
		--	320, 240
		--)
		self.viewPort = Viewport(0, 0, width, height)

		self.canvas = Canvas()
		self.interactionMaster = InteractionMaster(self.viewPort)
		interactionMaster = self.interactionMaster -- Make a nice global variable!

		-- Create HUD if a HUD class was given
		if (self.hudClass) then
			self.hud = self.hudClass()
			self.interactionMaster:addInteraction(self.hud)
			hud = self.hud -- Yeah, make it global!
		end

		-- Add the conversation box
		self.interactionMaster:addInteraction(convBox)

		-- Create menu if a menu class was given
		if (self.mainMenuClass) then
			self.mainMenu = self.mainMenuClass()
			self.interactionMaster:addInteraction(self.mainMenu)
		end
	end;

	getText = function(self, id)
		if (self.textProvider) then
			return self.textProvider:getText(id, self.lang)
		end
	end;


	--
	-- This function is called every game update, right before all objects get
	-- updated.
	--
	event_logic_update = function(self)
		ActionController:update()
		MusicControl:update()

		self.interactionMaster:processTick()

		if (playerController and m_get_ex_mode() == 0) then
			m_update_input(playerController)
			playerController:playerTick()
		end
	end;


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
	event_render = function(self)
		self.interactionMaster:processPreRender()

		if (not show_main_menu and self.viewPort) then
			self.viewPort:render()
		end

		-- Set HUD to invisible while main menu is shown
		if (self.hud) then
			self.hud.bVisible = not show_main_menu
		end

		if (map_fade ~= nil and map_fade.alpha ~= nil and map_fade.alpha > 0) then
			local w,h = m_screen_size()
			m_set_alpha(map_fade.alpha)
			m_set_cursor(0,0)
			self.canvas:drawRect(m_get_bitmap("pixel_black.bmp"), w, h)
			m_set_alpha(255)
		end

		self.interactionMaster:processPostRender(self.canvas)
	end;

	event_keypress = function(self, key)
		--m_message(key.." key has been pressed!")

		if (self.interactionMaster:processKeyType(key)) then return true end

		if (key == "esc") then
			if (self.ingameMenuClass) then
				self.interactionMaster:addInteraction(self.ingameMenuClass())
			else
				m_quit_game()
			end
			return true
		end
	end;


	defaultproperties = {
		startupSequence = {},
		conversationWindowClass = ConversationWindow,
		guiThemeClass = GuiTheme,
		hudClass = nil,
		playerClass = nil,
		mainMenuClass = nil,
		ingameMenuClass = nil,
		textProviderClass = nil,
		textProvider = nil,
		mainMenu = nil,
		viewPort = nil,
		lang = "en",
	}
}


--
-- Below here some ugly leftovers
--


game = {
	game_over = 0,
	game_over_alpha = 0,
}

camera = {
	target = nil,
}




--
-- A helper function used by scripts that want to show a conversation.
--
function write_conversation(data)
	local conversation = {}

	for index, value in pairs(data) do
		local name = value[1]

		-- WARNING: Only works for BBRpg!
		--[[
		if (name == "{PLAYER}") then
			player = playerSwitcher:getCurrentHost()
			if (player) then
				name = player.name
			end
		end
]]

		table.insert(conversation, name..": \""..value[2].."\"")
	end

	local n = #conversation
	convBox.lines = {}
	convBox.lines_todo = {}
	convBox.state = CB_CLOSED
	convBox.scroll = 0
	convBox.curr_char = 1
	convBox.continue = nil
	for i = 1, n do
		convBox:write_line(conversation[i])
	end
end

--
-- Another helper function to make it easier to choose a random thing to say, unequal
-- to what was said last time.
--
function get_new_n(old_n, max_n)
	local n
	if (max_n > 1) then
		repeat n = math.random(max_n) until (n ~= old_n)
	else n = max_n end
	return n
end
