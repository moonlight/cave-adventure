--
-- The InteractionMaster controls the entire interaction system.  It's
-- job is to take input, postRender and tick calls and route them to
-- individual interactions.
--
-- By Bjorn Lindeijer


import("Object.lua")

InteractionMaster = Object:subclass
{
	name = "InteractionMaster";

	init = function(self, viewport)
		self.viewport = viewport
	end;

	addInteraction = function(self, interaction)
		table.insert(self.globalInteractions, 1, interaction)
		interaction:setInteractionMaster(self)
	end;

	removeInteraction = function(self, interaction)
		local interactionArray
		local iIndex

		interactionArray = self.globalInteractions

		-- Search for the Interaction
		iIndex = -1;
		for i = 1, #interactionArray do
			if (interactionArray[i] == interaction) then
				iIndex = i
			end
		end

		-- Whas it found?
		if (iIndex < 0) then
			m_message("Attempt to remove non-existing interaction.")
		else
			interactionArray[iIndex]:setInteractionMaster(nil)
			table.remove(interactionArray, iIndex)
		end
	end;


	setFocusTo = function(self, interaction, viewportOwner)
		local interactionArray
		local temp
		local i, iIndex

		--if (ViewportOwner ~= nil) then
		--	InteractionArray = ViewportOwner.LocalInteractions
		--else
			interactionArray = self.globalInteractions
		--end

		if (#interactionArray) == 0 then
			m_message("Attempt to setFocusTo with an empty interactions array.");
			return
		end

		-- Search for the Interaction
		iIndex = -1;
		for i = 1, #interactionArray do
			if (interactionArray[i] == interaction) then
				iIndex = i
			end
		end

		-- Was it found?
		if (iIndex < 0) then
			m_message("Attempt to set focus to a non-existing interaction ("..interaction..").")
			return
		elseif (iIndex == 1) then
			return -- Already has focus
		end

		-- Move it to the top.
		temp = interactionArray[iIndex]
		for i = iIndex, 2, -1 do
			interactionArray[i] = interactionArray[i-1]
		end
		interactionArray[1] = temp
		interactionArray[1].bActive = true  -- Give it Input
		interactionArray[1].bVisible = true -- Make it visible
	end;


	--
	-- The process functions take the events to the interactions.
	--

	processTick = function(self)
		local ia = self.globalInteractions

		for i = 1, #ia do
			if (ia[i].bRequiresTick) then
				ia[i]:tick()
			end
		end
	end;

	processPreRender = function(self)
		local ia = self.globalInteractions

		for i = 1, #ia do
			if (ia[i].bVisible) then
				ia[i]:preRender()
			end
		end
	end;

	processPostRender = function(self, canvas)
		local ia = self.globalInteractions

		for i = #ia, 1, -1 do
			if (ia[i].bVisible) then
				ia[i]:postRender(canvas)
			end
		end
	end;

	processKeyType = function(self, key)
		local ia = self.globalInteractions

		for i = 1, #ia do
			if (ia[i].bActive) then
				if (ia[i]:keyType(key)) then
					return true -- No further processing when key is used
				end
			end
		end

		return false
	end;

	processLevelChange = function(self, level)
		local ia = self.globalInteractions

		for i = 1, #ia do
			ia[i]:levelChange(level)
		end
	end;


	defaultproperties = {
		globalInteractions = {},
		viewport = nil,
	};
}
