
import("Object.lua")


Viewport = Object:subclass
{
	name = "Viewport";

	init = function(self, x, y, w, h)
		self.x = x or self.x
		self.y = y or self.y
		self.w = w or self.w
		self.h = h or self.h
	end;

	mapToScreen = function(self, x, y, z)
		if (not self.target or not self.target.map) then return end

		if (not z) then z = 0 end

		return m_map_to_screen(
			x, y, z,
			self.x, self.y,
			self.w, self.h,
			self.target.x, self.target.y, self.target.map
		)
	end;

	screenToMap = function(self, x, y)
		if (not self.target or not self.target.map) then return end
		
		return m_screen_to_map(
			x, y,
			self.x, self.y,
			self.w, self.h,
			self.target.x, self.target.y, self.target.map
		)
	end;

	render = function(self)
		if (not self.target or not self.target.map) then return end

		if (self.target) then
			m_draw_viewport(
				self.x, self.y,
				self.w, self.h,
				self.target.x, self.target.y,
				self.target.map
			)
		end
	end;

	defaultproperties = {
		x = 0,
		y = 0,
		w = 0,
		h = 0,
		target = nil,
	};
}
