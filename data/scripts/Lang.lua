--
-- Contains all the stuff that is being said in the game
-- By Bjorn Lindeijer

--
-- This object holds written text, to easy translation of the game. Variables
-- starting with a 'c' are conversations.
--

import("Object.lua")

Lang = Object:subclass
{
	name = "Lang";

	getConv = function(self, convName)
		local conv = self.convs[convName]

		if (conv) then
			-- Replace variables

			return conv
		else
			m_message("Warning: no such conversation ("..convName..")")
			return {}
		end
	end;

	getVar = function(self, varName)
		local var = self.vars[varName]
		if (var) then return var else
			m_message("Warning: no such variable ("..varName..")")
			return ""
		end
	end;

	vars = {};
	convs = {};
}
