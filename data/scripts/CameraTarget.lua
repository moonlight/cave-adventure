
import("Object.lua")


CameraTarget = Object:subclass
{
	name = "CameraTarget";

	setTarget = function(self, target, tween)
		if (tween == nil) then tween = true end

		if (not self.target or self.target.map ~= target.map or not tween) then
			self.fromX = target.x
			self.fromY = target.y
			self.x = target.x
			self.y = target.y
			self.progress = 100
		else
			self.fromX = self.x
			self.fromY = self.y
		end
		self.target = target
		self.map = self.target.map
		self.progress = 0
	end;

	tick = function(self)
		if (self.progress < 100) then
			self.progress = self.progress + 2
		end
	end;

	preRender = function(self)
		self.map = self.target.map

		if (self.progress < 100) then
			local p = math.sin((self.progress / 100) * 0.5 * math.pi)
			self.x = self.fromX + (self.target.x - self.fromX) * p
			self.y = self.fromY + (self.target.y - self.fromY) * p
		else
			self.x = self.target.x
			self.y = self.target.y
		end
	end;

	defaultproperties = {
		x = 0,
		y = 0,
		map = nil,
		target = nil,
		travel = 1,
		tweenAction = nil,
		progress = 0,
	};
}
