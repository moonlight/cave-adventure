--
-- This file contains the code for putting the HUD on the screen.
-- By Bjorn Lindeijer

import("Interaction.lua")




--
-- The actual HUD.
--
Hud = Interaction:subclass
{
	name = "Hud";

	init = function(self)
		-- Screen size
		self.screen_w, self.screen_h = m_screen_size()
			   
		-- Health bar images
		self.hb_empty = m_get_bitmap("healthbar_empty.bmp")
		self.hb_full = m_get_bitmap("healthbar_full.bmp")
		self.hb_w, self.hb_h = m_bitmap_size(self.hb_full)
		
		-- Experience bar images
		self.eb_empty = m_get_bitmap("expbar_empty.bmp")
		self.eb_full = m_get_bitmap("expbar_full.bmp")
		self.eb_w, self.eb_h = m_bitmap_size(self.eb_full)
		
		-- Game over image
		self.game_over = m_get_bitmap("game_over.bmp")
		self.game_over_s = m_get_bitmap("game_over_s.bmp")
		self.go_w, self.go_h = m_bitmap_size(self.game_over)
	end;

	-- A chance to put something on the screen (requires bVisible)
	postRender = function(self, canvas)
		--[[
		local player = m_get_player()
		local health_perc = player.health / player.maxHealth
		local experience_perc = player.experience / player.nextLevelExperience
		
		-- Draw the health bar
		m_set_alpha(128)
		m_set_cursor(16, 16)
		draw_icon(self.hb_empty)
		m_set_cursor(16, 16)
		draw_pattern(self.hb_full, self.hb_w * health_perc, self.hb_h)
		
		-- Draw the experience bar
		m_set_cursor(16, 27)
		draw_icon(self.eb_empty)
		m_set_cursor(16, 27)
		draw_pattern(self.eb_full, self.eb_w * experience_perc, self.eb_h)
		m_set_alpha(255)
        ]]

		-- Map name
		if (self.map_name ~= nil and self.map_name_alpha > 0) then
			local w, h = m_bitmap_size(self.map_name)
			local x, y = (self.screen_w - w)/2, (self.screen_h - h)/6 * 5
			
			local alpha = self.map_name_alpha
			-- Take map fading into account
			if (map_fade ~= nil and map_fade.alpha ~= nil and map_fade.alpha > 0) then
				alpha = alpha * (255 - map_fade.alpha) / 255
			end
			
			canvas:setCursor(x, y);
			canvas:setAlpha(0.75 * alpha);
			canvas:drawIcon(self.map_name)
			
			canvas:setCursor(0, y - 10);
			canvas:setAlpha(alpha);
			canvas:drawRect(m_get_bitmap("pixel_black.bmp"), self.screen_w, 1)
			
			canvas:setCursor(0, y - 10);
			canvas:setAlpha(0.25 * alpha);
			canvas:drawRect(m_get_bitmap("pixel_black.bmp"), self.screen_w, h + 20)

			canvas:setCursor(0, y + h + 10);
			canvas:setAlpha(alpha);
			canvas:drawRect(m_get_bitmap("pixel_black.bmp"), self.screen_w, 1)
		end
		
		-- Draw gameover screen stuff
		if (game.game_over and game.game_over_alpha and game.game_over_alpha > 0) then
			canvas:setAlpha(0.25 * game.game_over_alpha)
			canvas:setCursor((self.screen_w - self.go_w)/2 + 6, (self.screen_h - self.go_h)/3 + 4)
			canvas:drawIcon(self.game_over_s)
			canvas:setAlpha(game.game_over_alpha)
			canvas:setCursor((self.screen_w - self.go_w)/2, (self.screen_h - self.go_h)/3)
			canvas:drawIcon(self.game_over)
		end
	end;

	defaultproperties = {
		count = 0,
		map_name_alpha = 0,
	}
}
