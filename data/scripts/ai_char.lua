-- ai_char.lua
-- A character combined with an AI
--

CommonAIChar = {}

function CommonAIChar:event_init()
	inherit(self, BasicChar)
	inherit(self, BasicCharAni)
	inherit(self, CommonAI)

	-- Restore own functions
	self.tick = CommonAIChar.tick

	CommonAI.event_init(self)
end

function CommonAIChar:tick()
	CommonAI.tick(self)
	BasicCharAni.tick(self)
end
