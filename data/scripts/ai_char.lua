-- ai_char.lua
-- A character combined with an AI
--

CommonAIChar = {}

function CommonAIChar:event_init()
	inherit(self, BasicChar)
	inherit(self, BasicCharAni)
	inherit(self, CommonAI)

	-- Restore own functions
	self.event_tick = CommonAIChar.event_tick

	CommonAI.event_init(self)
end

function CommonAIChar:event_tick()
	CommonAI.event_tick(self)
	BasicCharAni.event_tick(self)
end
