--
-- Interactions are the foundation for any subsystem that requires interaction
-- with the player (such as a menu). One InteractionMaster is used to handle
-- all the interactions.
--
-- By Bjorn Lindeijer


import("Object.lua")

Interaction = Object:subclass
{
	name = "Interaction";

	-- Tick function, disabled by default but can be activated by setting
	-- bRequiresTick to true.
	tick = function(self)
	end;

	-- Receives a key description string, should return true when key was
	-- used by this interaction.
	keyType = function(self, key)
		return false
	end;

	-- A notification that the current level has changed together with the
	-- name of the level (the map path, but this should change)
	levelChange = function(self, level)
	end;

	-- A chance to change something just before rendering takes place (requires bVisible)
	preRender = function(self)
	end;

	-- A chance to put something on the screen (requires bVisible)
	postRender = function(self, canvas)
	end;

	-- Sets the focus on this interaction
	setFocus = function(self)
		self.master.setFocusTo(self, self.viewportOwner);
	end;

	-- Changes the interactionmaster
	setInteractionMaster = function(self, master)
		self.master = master
	end;

	defaultproperties = {
		bActive = true,        -- Is this interaction Getting Input
		bVisible = true,       -- Is this interaction being Displayed
		bRequiresTick = false, -- Does this interaction require game Tick
		master = nil,          -- The interaction master
		viewportOwner = nil,   -- Owner of the viewport, ie. the player
	};
}
