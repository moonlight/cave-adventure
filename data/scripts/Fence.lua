-- fences.lua
-- Fences... they can prevent people from leaving or entering a certain area.
-- By Frode Lindeijer

import("Object.lua")


Fence = Actor:subclass
{
	name = "Fence";
	defaultproperties = {
		obstacle = 1,
		w = 1,
		h = 1,
		draw_mode = DM_MASKED,
	}
}


FenceR  = Fence:subclass{ name = "FenceR";  defaultproperties = { bitmap = m_get_bitmap("fence_r.bmp" ) } }
Fence1  = Fence:subclass{ name = "Fence1";  defaultproperties = { bitmap = m_get_bitmap("fence_1.bmp" ) } }
Fence2  = Fence:subclass{ name = "Fence2";  defaultproperties = { bitmap = m_get_bitmap("fence_2.bmp" ) } }
FenceG2 = Fence:subclass{ name = "FenceG2"; defaultproperties = { bitmap = m_get_bitmap("fence_gc.bmp") } }
FenceL  = Fence:subclass{ name = "FenceL";  defaultproperties = { bitmap = m_get_bitmap("fence_l.bmp" ) } }

--

FENCE_CLOSED = 0
FENCE_OPEN   = 1

FenceG = Fence:subclass
{
	name = "FenceG";

	init = function(self)
		Fence.init(self)
		self:updateBitmap()
	end;

	updateBitmap = function(self)
		if (self.state == FENCE_CLOSED) then
			self.bitmap = m_get_bitmap("fence_gc.bmp")
			self.obstacle = 1
		else
			self.bitmap = m_get_bitmap("fence_go.bmp")
			self.obstacle = 0
		end
	end;

	setState = function(self, state)
		self.state = state
		self:update_bitmap()
	end;

	activatedBy = function(self, instigator)
		if (self.first_time == 1) then
			self.first_time = 0
			ActionController:addSequence({
				ActionExModeOn(),
				ActionConversation(lang:getConv("YEAH_RIGHT")),
				ActionSetState(self, FENCE_OPEN),
				ActionConversation(lang:getConv("NOT_LOCKED")),
				ActionSetState(caveman_guard1, AI_READY),
				ActionSetState(caveman_guard2, AI_READY),
				ActionSetState(caveman_guard3, AI_READY),
				ActionSetState(caveman_guard4, AI_READY),
				ActionExModeOff(),
			})
		else
			self:setState(1 - self.state)
		end
	end;

	defaultproperties = {
		bitmap = m_get_bitmap("fence_r.bmp"),
		first_time = 1,
		state = FENCE_CLOSED,
	};
}
