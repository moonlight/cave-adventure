--
-- Controller, the base class of players or AI. 
--
-- Controllers are non-physical and can be attached to a Actor to control 
-- its actions. PlayerControllers are used by human players to control pawns,
-- while AIControllers implement the artificial intelligence for the
-- Actors they control.
--
-- Controllers take control of a pawn using their Possess() method, and
-- relinquish control of the pawn by calling UnPossess().
--
-- Controllers receive notifications for many of the events occuring for the
-- Actor they are controlling. This gives the controller the opportunity
-- to implement the behavior in response to this event.
--
-- This class is heavily based upon the architecture of the Unreal Engine.
--
-- By Bjorn Lindeijer

import("Object.lua")


Controller = Object:subclass
{
	name = "Controller";

	--== POSSESSING ==--

	possess = function(self, pawn)
		self:unPossess()
		pawn:possessedBy(self)
		self.pawn = pawn
	end;

	unPossess = function(self)
		if (self.pawn) then
			self.pawn:unPossessed()
			self.pawn = nil
		end
	end;


	--== NOTIFYCATIONS ==--

	notifyTakeDamage = function(self, actualDamage, instigator, damageType, momentum, location)
	end;

	notifyHearNoise = function(self, loadness, noiseMaker)
	end;

	notifyBumpInto = function(self, obj)
	end;

	notifyBumpedInto = function(self, obj)
	end;

	notifyWalkFinished = function(self)
	end;


	tick = function(self)
	end;


	defaultproperties =
	{
		-- The Pawn possessed by this Controller
		pawn = nil,
	}
}