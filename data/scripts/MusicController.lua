--
-- This file contains the music controller. It can be told to play and stop
-- songs. As a bonus, it can also dynamically change the parameters of a
-- channel over a period of time. Using this feature it can fade from one
-- music to another.
--
-- By Bjorn Lindeijer

MC_NORMAL         = 0
MC_FADE_IN        = 1
MC_FADE_OUT       = 2
MC_FADE_BETWEEN   = 3


MusicControl = {
	state = MC_NORMAL,
	currentChannel = -1,
	fadeInChannel = 1,
	fadeProgress = 0,
	fadeTime = 0,
}

function MusicControl:init()
	self.channels = m_get_number_of_channels() or 0
end

function MusicControl:update()
	if (self.state == MC_FADE_BETWEEN or self.state == MC_FADE_IN or self.state == MC_FADE_OUT) then
		self.fadeProgress = self.fadeProgress + 1

		if (self.state == MC_FADE_BETWEEN) then
			if (self.fadeProgress > self.fadeTime or self.fadeTime <= 0) then
				self.state = MC_NORMAL
				self.fadeProgress = self.fadeTime

				m_stop_music(self.currentChannel)
				self.currentChannel = self.fadeInChannel
				m_adjust_channel(self.currentChannel, 255, 128, 1000)
			else
				m_adjust_channel(self.fadeInChannel, (self.fadeProgress / self.fadeTime) * 255, 128, 1000)
				m_adjust_channel(self.currentChannel, ((self.fadeTime - self.fadeProgress) / self.fadeTime) * 255, 128, 1000)
			end
		end

		if (self.state == MC_FADE_IN) then
			if (self.fadeProgress > self.fadeTime or self.fadeTime <= 0) then
				self.state = MC_NORMAL
				self.fadeProgress = self.fadeTime

				m_adjust_channel(self.currentChannel, 255, 128, 1000)
			else
				m_adjust_channel(self.currentChannel, (self.fadeProgress / self.fadeTime) * 255, 128, 1000)
			end
		end

		if (self.state == MC_FADE_OUT) then
			if (self.fadeProgress > self.fadeTime or self.fadeTime <= 0) then
				self.state = MC_NORMAL
				self.fadeProgress = self.fadeTime

				m_stop_music(self.currentChannel)
				self.currentChannel = -1
			else
				m_adjust_channel(self.currentChannel, ((self.fadeTime - self.fadeProgress) / self.fadeTime) * 255, 128, 1000)
			end
		end
	end
end

function MusicControl:play_song(filename)
	self:stop_all_music()

	-- play this song on the first channel
	self.currentChannel = 0
	self.currentSong = filename
	m_play_music(filename, self.currentChannel)
	m_adjust_channel(self.currentChannel, 255, 128, 1000)
end

function MusicControl:stop_all_music()
	-- stop music on all channels
	for i = 0,self.channels-1 do
		m_stop_music(i)
	end
end

function MusicControl:fade_to_song(filename, time)
	if (not (time > 0)) then
		self:play_song(filename)
		return
	end

	if (self.currentChannel == -1) then
		self:fade_in(filename, time)
		return
	end

	self.state = MC_FADE_BETWEEN
	self.fadeTime = time
	self.fadeProgress = 0

	self.fadeInChannel = self.currentChannel + 1
	if (self.fadeInChannel == self.channels) then self.fadeInChannel = 0 end

	-- Start playing music and set volume to 0
	self.currentSong = filename
	m_play_music(filename, self.fadeInChannel)
	self:update()
end

function MusicControl:fade_out(time)
	if (self.currentChannel >= 0) then
		self.state = MC_FADE_OUT
		self.fadeTime = time
		self.fadeProgress = 0
	else
		m_message("MusicControl:fade_out - Warning, no music to fade out")
	end
end

function MusicControl:fade_in(filename, time)
	self:play_song(filename)
	self.state = MC_FADE_IN
	self.fadeTime = time
	self.fadeProgress = 0
	m_adjust_channel(self.currentChannel, 0, 128, 1000)
end