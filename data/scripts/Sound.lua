--
-- A sound object that can be either a short sample or an entire song. It can
-- fade out and in and can be set to loop.
-- By Bjorn Lindeijer

import("Object.lua")

Sound = Object:subclass
{
	name = "Sound";

	start = function(self, fadeInTime)
		if (self.channel == nil) then
			self.channel = request_channel()
		end
	end;

	stop = function(self, fadeOutTime)
	end;

	tick = function(self)
	end;

	setLooping = function(self, loop)
		self.loop = loop
	end;


	defaultproperties = {
		loop = false,
		channel = nil,
	}
}