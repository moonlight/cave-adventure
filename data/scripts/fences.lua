-- fences.lua
-- Fences... they can prevent people from leaving or entering a certain area.
-- By Frode Lindeijer

import("Object.lua")


FenceR = {}
Fence1 = {}
Fence2 = {}
FenceG2 = {}
FenceG = {}
FenceL = {}

--

function FenceR:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("fence_r.bmp")
	self.w = 1
	self.h = 1
end


--

function Fence1:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("fence_1.bmp")
	self.w = 1
	self.h = 1
end


--

function Fence2:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("fence_2.bmp")
	self.w = 1
	self.h = 1
end


--

function FenceG2:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.w = 1
	self.h = 1
	self.first_time = 1
	self.open = 0
	self.bitmap = m_get_bitmap("fence_gc.bmp")
	self.obstacle = 1
end


--

FENCE_CLOSED = 0
FENCE_OPEN   = 1

function FenceG:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.w = 1
	self.h = 1
	self.first_time = 1
	self.state = FENCE_CLOSED
	self:update_bitmap()
end

function FenceG:update_bitmap()
	if (self.state == FENCE_CLOSED) then
		self.bitmap = m_get_bitmap("fence_gc.bmp")
		self.obstacle = 1
	else
		self.bitmap = m_get_bitmap("fence_go.bmp")
		self.obstacle = 0
	end
end

function FenceG:setState(state)
	self.state = state
	self:update_bitmap()
end

function FenceG:event_activate(instigator)
	if (self.first_time == 1) then
		self.first_time = 0
		ActionController:addSequence({
			ActionExModeOn(),
			ActionConversation(conv.YEAH_RIGHT),
			ActionSetState(self, FENCE_OPEN),
			ActionConversation(conv.NOT_LOCKED),
			ActionSetState(caveman_guard1, AI_READY),
			ActionSetState(caveman_guard2, AI_READY),
			ActionSetState(caveman_guard3, AI_READY),
			ActionSetState(caveman_guard4, AI_READY),
			ActionExModeOff(),
		})
	else
		self:setState(1 - self.state)
	end
end


--

function FenceL:event_init()
	inherit(self, BasicObject)

	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("fence_l.bmp")
	self.w = 1
	self.h = 1
end