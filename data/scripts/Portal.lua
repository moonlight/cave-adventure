--
-- A general portal class, for transporting players from one map to another.
--

import("Actor.lua")

Portal = Actor:subclass
{
	name = "Portal";

	event_bumped_into = function(self, actor)
		if (not self.linkedPortal) then return end

		if (actor:instanceOf(Player)) then
			if (self.onUse) then
				self.onUse()
			end

			actor:walk(actor.dir, true)

			local musicOut = ActionFadeOutMusic(100 / actor.speed)
			local musicIn = ActionPlaySong(self.linkedPortal.myMap.musicFilename, 100 / actor.speed)

			if (self.linkedPortal.myMap.musicFilename == MusicControl.currentSong) then
				musicOut = ActionWait(0)
				musicIn = ActionWait(0)
			end

			ActionController:addSequence{
				ActionExModeOn(),
				ActionParallel{
					ActionWalk(actor, actor.dir, 1, false),
					musicOut,
					ActionFadeOutMap(100 / actor.speed),
				},
				ActionCallFunction(actor.setMap, actor, self.linkedPortal.myMap),
				ActionSetPosition(actor, self.linkedPortal.x, self.linkedPortal.y),
				ActionParallel{
					musicIn,
					ActionFadeInMap(100 / actor.speed),
					ActionSequence{
						ActionCallFunction(actor.walk, actor, self.linkedPortal.outDir),
						ActionCallFunction(actor.walk, actor, self.linkedPortal.outDir, true),
					}
				},
				ActionShowMapName(self.linkedPortal.myMap.mapNameBitmap),
				ActionExModeOff(),
			}
		end
	end;

	setOutDir = function(self, outDir)
		self.outDir = outDir or self.outDir
	end;

	linkToPortal = function(self, portal)
		if (portal:instanceOf(Portal)) then
			self.linkedPortal = portal
		else
			error("Type error, expected object of type Portal.")
		end
	end;

	defaultproperties = {
		linkedPortal = nil,
		bitmap = nil, --m_get_bitmap("target.tga"),
		draw_mode = DM_ALPHA,
		w = 1,
		h = 1,
		obstacle = 1,
		outDir = DIR_NONE,
	};
}
