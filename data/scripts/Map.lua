--
-- The Map class
-- By Bjorn Lindeijer


import("Object.lua")

Map = Object:subclass
{
	name = "Map";

	init = function(self, mapName)
		self.map = m_load_map(mapName)
		if (not self.map or type(self.map) ~= "userdata") then
			error("Error while loading map \"".. mapName.."\"!")
		end

		-- Call beginPlay on all actors in the map
		local objs = m_get_objects_on_map(self.map)
		for k,v in pairs(objs) do
			if (v:instanceOf(Actor)) then
				v:beginPlay()
			end
		end
	end;

	spawn = function(self, class, x, y, owner)
		return Actor:spawn(class, x, y, self, owner)
	end;

	defaultproperties = {
		map = nil,
		mapNameBitmap = nil,
		musicFilename = "",
	}
}
