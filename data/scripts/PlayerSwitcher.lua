-- This class makes it possible to switch between multiple player hosts
-- and displays their information on the screen.
--
-- By Bjorn Lindeijer

import("Interaction.lua")


PlayerSwitcher = Interaction:subclass
{
	name = "PlayerSwitcher";

	init = function(self, playerController, cameraTarget)
		self.playerHosts = {}
		self.playerController = playerController
		self.cameraTarget = cameraTarget

		-- Health bar images
		self.hb_empty = m_get_bitmap("healthbar_empty.bmp")
		self.hb_full = m_get_bitmap("healthbar_full.bmp")
		self.hb_w, self.hb_h = m_bitmap_size(self.hb_full)
		
		-- Experience bar images
		self.eb_empty = m_get_bitmap("expbar_empty.bmp")
		self.eb_full = m_get_bitmap("expbar_full.bmp")
		self.eb_w, self.eb_h = m_bitmap_size(self.eb_full)		
	end;

	addPlayerHost = function(self, playerHost)
		if (not playerHost) then
			error("Attempt to add non-existing player host!")
		end

		table.insert(self.playerHosts, playerHost)

		if (self.currentHost == 0) then
			self:selectPlayerHost(playerHost)
		end
	end;

	removePlayerHost = function(self, playerHost)
		local iIndex = self:hostIndex(playerHost)

		if (iIndex < 0) then
			m_message("Attempt to remove non-existing player host.")
		else
			table.remove(self.playerHosts, iIndex)
			if (iIndex == self.currentHost) then
				if (self.currentHost > #self.playerHosts) then
					self.currentHost = 1
				end

				if #self.playerHosts > 0 then
					self:selectPlayerHost(self.playerHosts[self.currentHost])
				else
					self.playerController:unPossess()
					self.currentHost = 0
				end
			end
		end
	end;

	selectPlayerHost = function(self, playerHost)
		local iIndex = self:hostIndex(playerHost)

		if (iIndex < 0) then
			m_message("Attempt to select non-existing player host.")
		else
			self.playerController:possess(playerHost)
			self.currentHost = iIndex
			self.cameraTarget:setTarget(playerHost)
		end
	end;

	getCurrentHost = function(self)
		if (self.currentHost > 0) then
			return self.playerHosts[self.currentHost]
		end;
	end;

	hostIndex = function(self, playerHost)
		local iIndex

		-- Search for the Interaction
		iIndex = -1;
		for i = 1, #self.playerHosts do
			if (self.playerHosts[i] == playerHost) then
				iIndex = i
			end
		end

		return iIndex
	end;

	keyType = function(self, key)
		if (key == "tab" and #self.playerHosts > 0 and m_get_ex_mode() == 0) then
			local prevHost = self:getCurrentHost()

			if (m_get_shift()) then
				self.currentHost = self.currentHost - 1
				if (self.currentHost < 1) then
					self.currentHost = #self.playerHosts
				end
			else
				self.currentHost = self.currentHost + 1
				if (self.currentHost > #self.playerHosts) then
					self.currentHost = 1
				end
			end

			local nextHost = self:getCurrentHost()

			if (prevHost.map == nextHost.map) then
				-- Switch player instantly
				self:selectPlayerHost(self.playerHosts[self.currentHost])
			else
				local musicOut = ActionFadeOutMusic(50)
				local musicIn = ActionPlaySong(nextHost.myMap.musicFilename, 50)

				if (nextHost.myMap.musicFilename == MusicControl.currentSong) then
					musicOut = ActionWait(0)
					musicIn = ActionWait(0)
				end

				-- Switch player after fading out and fade in afterwards
				ActionController:addSequence{
					ActionSetVariable(self, "bActive", false),
					musicOut,
					ActionFadeOutMap(50),
					ActionCallFunction(self.selectPlayerHost, self, self.playerHosts[self.currentHost]),
					musicIn,
					ActionFadeInMap(50),
					ActionSetVariable(self, "bActive", true),
				}
			end

			return true;
		end;
	end;


	tick = function(self)
		self.cameraTarget:tick()
	end;

	preRender = function(self)
		self.cameraTarget:preRender()
	end;

	postRender = function(self, canvas)
		-- Draw information about each player
		-- and highlight the selected player

		for i = 1, #self.playerHosts do
			local player = self.playerHosts[i]
			local health_perc = player.health / player.maxHealth
			local experience_perc = player.experience / player.nextLevelExperience
			local x = 16 + (self.hb_w + 16) * (i - 1)
			local y = 16
			local invHeight = 19

			if (#player.inventory) == 0 then
				invHeight = 0
			end

			canvas:setDrawMode(DM_TRANS)

			-- Draw selection block
			if (i == self.currentHost) then
				guiTheme:drawBox(x - 3, y - 2, self.hb_w + 6, 14 + 5 + invHeight)
			end
			
			-- Draw the health bar
			canvas:setAlpha(128)
			canvas:setCursor(x, y)
			canvas:drawIcon(self.hb_empty)
			canvas:setCursor(x, y)
			canvas:drawPattern(self.hb_full, self.hb_w * health_perc, self.hb_h)
			
			-- Draw the experience bar
			canvas:setCursor(x, y + 11)
			canvas:drawIcon(self.eb_empty)
			canvas:setCursor(x, y + 11)
			canvas:drawPattern(self.eb_full, self.eb_w * experience_perc, self.eb_h)
			canvas:setAlpha(255)

			-- Draw inventory
			canvas:setCursor(x, y + 17)
			for k,v in pairs(player.inventory) do
				local x, y = m_get_cursor()
				guiTheme:drawLightBox(x, y, 16, 16)
				canvas:setCursor(x + 2, y + 2)
				if (v.inventoryBitmap) then
					canvas:drawRect(v.inventoryBitmap, 12, 12)
					canvas:moveCursor(3,-2)
				else
					canvas:moveCursor(3 + 12, -2)
				end
			end
		end

	end;

	defaultproperties = {
		playerHosts = {},
		cameraTarget = nil,
		playerController = nil,
		currentHost = 0,
		bRequiresTick = true,
		bVisible = true,
	}
}
