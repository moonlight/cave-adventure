--
-- A helper class to draw the HUD on.
--

import("Object.lua")


Canvas = Object:subclass
{
	name = "Canvas";

	drawBitmap = function(self, bitmap, dest_w, dest_h, src_x, src_y, src_w, src_h)
		m_draw_bitmap(bitmap, dest_w, dest_h, src_x, src_y, src_w, src_h)
	end;

	drawPattern = function(self, bitmap, dest_w, dest_h, org_x, org_y, scale)
		if (scale) then
			local cur_x, cur_y = m_get_cursor()
			m_draw_bitmap(bitmap, dest_w, dest_h, (cur_x - org_x) / scale, (cur_y - org_y) / scale, dest_w / scale, dest_h / scale)
		elseif (org_x and org_y) then
			local cur_x, cur_y = m_get_cursor()
			m_draw_bitmap(bitmap, dest_w, dest_h, cur_x - org_x, cur_y - org_y, dest_w, dest_h)
		else
			m_draw_bitmap(bitmap, dest_w, dest_h, 0, 0, dest_w, dest_h)
		end
	end;

	drawIcon = function(self, bitmap, scale)
		local bitmap_w, bitmap_h = m_bitmap_size(bitmap)
		if (not scale or scale == 1) then
			m_draw_bitmap(bitmap, bitmap_w, bitmap_h, 0, 0, bitmap_w, bitmap_h)
		else
			m_draw_bitmap(bitmap, bitmap_w * scale, bitmap_h * scale, 0, 0, bitmap_w, bitmap_h)
		end
	end;

	drawRect = function(self, bitmap, rect_x, rect_y)
		local bitmap_w, bitmap_h = m_bitmap_size(bitmap)
		m_draw_bitmap(bitmap, rect_x, rect_y, 0, 0, bitmap_w, bitmap_h)
	end;

	moveCursor = function(self, dx, dy)
		local x, y = self:getCursor()
		self:setCursor(x + dx, y + dy)
	end;

	setCursor = function(self, x, y)
		m_set_cursor(x, y)
	end;

	getCursor = function(self)
		return m_get_cursor()
	end;

	setAlpha = function(self, alpha)
		return m_set_alpha(alpha)
	end;

	setDrawMode = function(self, drawMode)
		m_set_drawmode(drawMode)
	end;
}
