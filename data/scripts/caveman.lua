-- caveman.lua
-- A basic caveman.
-- By Bjørn Lindeijer

Caveman = {}

function Caveman:event_init()
	inherit(self, BasicChar)
	inherit(self, BasicCharAni)

	self.draw_mode = DM_MASKED
	self.speed = 2
	self:start_animation(caveman_anim)
end

function Caveman:activatedBy(instigator)
end


--
-- The caveman enemy object
--

EnemyCaveman = {}

function EnemyCaveman:event_init()
	inherit(self, CommonAIChar)
	self:event_init(self)

	self.draw_mode = DM_MASKED
	self:start_animation(caveman_anim)

	self.speed = 2
	self.experience = 17
end

function EnemyCaveman:do_death()
	self.animation = nil
	self.bitmap = m_get_bitmap("caveman_dead.bmp")
	self.offset_y = self.offset_y + 3
	ActionController:addSequence({
		ActionWait(100),
		ActionSetVariable(self, "draw_mode", DM_TRANS),
		ActionTweenVariable(self, "alpha", 200, 0),
		ActionDestroyObject(self),
	})
end

function EnemyCaveman:attack_object(obj)
	SpawnSparkyHit(obj.x, obj.y, obj.offset_x, obj.offset_y, obj.offset_z + 24)
end


--
-- The caveman slave object
--

CavemanSlave = {}

function CavemanSlave:event_init()
	inherit(self, BasicChar)
	inherit(self, BasicCharAni)

	self.draw_mode = DM_MASKED
	self.speed = 2
	self:start_animation(caveman_slave_anim)
end

function CavemanSlave:activatedBy(instigator)
end


--
-- A dead slave
--

SlaveDead = {}

function SlaveDead:event_init()
	inherit(self, BasicChar)
	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("slave_dead.bmp")
end