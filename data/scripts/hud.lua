-- hud.lua
-- This file contains the code for putting the HUD on the screen.
-- By Bj�rn Lindeijer


--
-- Some helper functions to make HUD drawing easier, because m_draw_bitmap is
-- not very convenient generally.
--

function draw_pattern(bitmap, dest_w, dest_h, org_x, org_y, scale)
	if (scale) then
		local cur_x, cur_y = m_get_cursor()
		m_draw_bitmap(bitmap, dest_w, dest_h, (cur_x - org_x) / scale, (cur_y - org_y) / scale, dest_w / scale, dest_h / scale)
	elseif (org_x and org_y) then
		local cur_x, cur_y = m_get_cursor()
		m_draw_bitmap(bitmap, dest_w, dest_h, cur_x - org_x, cur_y - org_y, dest_w, dest_h)
	else
		m_draw_bitmap(bitmap, dest_w, dest_h, 0, 0, dest_w, dest_h)
	end
end

function draw_icon(bitmap, scale)
	local bitmap_w, bitmap_h = m_bitmap_size(bitmap)
	if (not scale or scale == 1) then
		m_draw_bitmap(bitmap, bitmap_w, bitmap_h, 0, 0, bitmap_w, bitmap_h)
	else
		m_draw_bitmap(bitmap, bitmap_w * scale, bitmap_h * scale, 0, 0, bitmap_w, bitmap_h)
	end
end

function draw_rect(bitmap, rect_x, rect_y)
	local bitmap_w, bitmap_h = m_bitmap_size(bitmap)
	m_draw_bitmap(bitmap, rect_x, rect_y, 0, 0, bitmap_w, bitmap_h)
end

function move_cursor(dx, dy)
	local x, y = m_get_cursor()
	m_set_cursor(x + dx, y + dy)
end


--
-- The actual HUD.
--
HUD = {
	count = 0,
	map_name_alpha = 0,
}

function HUD:initialize()
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
end

function HUD:logic_update()
end

function HUD:draw()
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

	-- Map name
	if (self.map_name ~= nil and self.map_name_alpha > 0) then
		local w, h = m_bitmap_size(self.map_name)
		local x, y = (self.screen_w - w)/2, (self.screen_h - h)/6 * 5

		local alpha = self.map_name_alpha
		-- Take map fading into account
		if (map_fade ~= nil and map_fade.alpha ~= nil and map_fade.alpha > 0) then
			alpha = alpha * (255 - map_fade.alpha) / 255
		end

		m_set_cursor(x, y);      m_set_alpha(0.75 * alpha); draw_icon(self.map_name)
		m_set_cursor(0, y - 10); m_set_alpha(alpha);        draw_rect(m_get_bitmap("pixel_black.bmp"), self.screen_w, 1)
		m_set_cursor(0, y - 10); m_set_alpha(0.25 * alpha); draw_rect(m_get_bitmap("pixel_black.bmp"), self.screen_w, h + 20)
		m_set_cursor(0, y + h + 10); m_set_alpha(alpha);    draw_rect(m_get_bitmap("pixel_black.bmp"), self.screen_w, 1)
	end

	-- Draw gameover screen stuff
	if (game.game_over and game.game_over_alpha and game.game_over_alpha > 0) then
		m_set_alpha(0.25 * game.game_over_alpha)
		m_set_cursor((self.screen_w - self.go_w)/2 + 6, (self.screen_h - self.go_h)/3 + 4)
		draw_icon(self.game_over_s)
		m_set_alpha(game.game_over_alpha)
		m_set_cursor((self.screen_w - self.go_w)/2, (self.screen_h - self.go_h)/3)
		draw_icon(self.game_over)
	end
end