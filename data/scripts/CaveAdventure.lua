
import("Game.lua")
import("Player.lua")


CaveAdventure = Game:subclass
{
	name = "CaveAdventure";

	init = function(self)
		-- Create language object
		lang = CaveLang()               -- WARNING: Bad design, introducing global variable

		-- Call superfunction
		Game.init(self)

		-- Load tile bitmaps
		m_import_tile_bmp("cave.bmp", 24, 24, 0)

		-- Load the maps
		cave1Map = Cave1()
		cave2Map = Cave2()
		cave3Map = Cave3()

		-- Spawn the player
		if (self.playerClass) then
			player = cave1Map:spawn(self.playerClass, -1, -1)
			playerController = PlayerController()
			playerController:possess(player)
			self.viewPort.target = player
		end

		--camera_handle = m_add_object(0, 0, "CameraHandle")
		--camera_handle.travel = 1


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
		ActionController:addSequence{
			ActionExModeOn(),
			ActionTweenVariable(main_menu_bg, "alpha", 200, 255),
			ActionTweenVariable(main_title, "y", 200, 184),
			ActionTweenVariable(main_start, "y", 100, 220),
		}

		-- Define startup sequence
		self.startupSequence = {
			ActionFadeOutMap(50),
			ActionSetVariable(_G, "show_main_menu", nil),
			ActionSetPosition(player, 50, 5, DIR_DOWN), -- Normal start position in cave 1
			--ActionSetPosition(m_get_player(), 25, 15, DIR_UP), -- Just before sequence in cave 2
			--ActionSetPosition(m_get_player(), 35, 19, DIR_UP), -- Just before starting boss fight in cave 3
			--ActionSetPosition(m_get_player(), 4, 5, DIR_LEFT), -- Near cave 1 exit to cave 2
			ActionPlaySong("data/music/Cave.ogg", 100),
			ActionFadeInMap(100),
			--ActionConversation(lang:getConv("INTRO")),
			ActionExModeOff(),
			ActionShowMapName(m_get_bitmap("cave_title_1.bmp")),
		}
	end;

	event_render = function(self)
		local width, height = m_screen_size()

		if (show_main_menu) then
			m_set_cursor(0,0)
			m_set_alpha(main_menu_bg.alpha)
			self.canvas:drawIcon(main_menu_bg.bm)
			self.canvas:setAlpha(255)
			m_set_drawmode(DM_ALPHA)
			self.canvas:setCursor(10, main_title.y); self.canvas:drawIcon(main_title.bm)
			self.canvas:setCursor(82, main_start.y); self.canvas:drawIcon(main_start.bm)
			m_set_drawmode(DM_MASKED)
		end

		Game.event_render(self)
	end;

	event_keypress = function(self, key)
		if (Game.event_keypress(self, key)) then return true end

		if (key == "action") then
			if (show_main_menu and not started) then
				started = 1
				ActionController:addSequence(self.startupSequence)
				return true
			end
		end
	end;

	defaultproperties = {
		playerClass = Player
	}
}
