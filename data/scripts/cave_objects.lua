-- cave_objects.lua
-- Cave-specific objects
--


CaveWaterfallExit = {}

function CaveWaterfallExit:event_init()
	inherit(self, LinearAni)

	self:start_animation(cave_waterfall_exit_anim)
	self.tick_time = 10
	self.draw_mode = DM_MASKED
end

function CaveWaterfallExit:event_activate(instigator)
	local text_table = {
		conv.NO_WAY_OUT,
		conv.NO_ESCAPE,
	}

	n = get_new_n(self.prev_random, getn(text_table))
	self.prev_random = n

	write_conversation(text_table[n])
end



--
-- Top, Roof and Bottom, used for caves you can walk through
--

CaveTunnelTop = {}

function CaveTunnelTop:event_init()
	self.draw_mode = DM_ALPHA
	self.bitmap = m_get_bitmap("cave_entrance2.tga")
	self.offset_z = 48
	self.offset_y = 24
end

CaveRoof = {}

function CaveRoof:event_init()
	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("cave_roof.bmp")
	self.offset_z = 48
	self.offset_y = 48
end

CaveTunnelBottom = {}

function CaveTunnelBottom:event_init()
	self.draw_mode = DM_ALPHA
	self.bitmap = m_get_bitmap("cave_entrance.tga")
	self.offset_z = 48
	self.offset_y = 28
end

-- Spider web

SpiderWeb = {}

function SpiderWeb:event_init()
	self.draw_mode = DM_ALPHA
	self.bitmap = m_get_bitmap("web.tga")
	self.offset_y = 7
	self.offset_x = 10
end

SpiderWeb2 = {}
function SpiderWeb2:event_init()
	self.draw_mode = DM_ALPHA
	self.bitmap = m_get_bitmap("web2.tga")
	self.offset_y = 7
	self.offset_x = -10
end


--
-- The horizontal bridge elements
--

CaveBridge1 = {}

function CaveBridge1:event_init()
	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("cavebridge1.bmp")
	self.offset_x = 0
	self.offset_y = -10
	self.offset_z = -10
end

CaveBridge2 = {}

function CaveBridge2:event_init()
	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("cavebridge2.bmp")
	self.offset_x = 0
	self.offset_y = 0
	self.offset_z = 0
end

-- Pile of rubble
CavePileTop = {}

function CavePileTop:event_init()
	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("rubble_t.bmp")
	self.offset_x = 24
	self.offset_y = 5
	self.offset_z = 0
	self.obstacle = 1
	self.w = 3
	self.h = 2
end	

CavePileBottom = {}

function CavePileBottom:event_init()
	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("rubble_b.bmp")
	self.offset_x = 24
	self.offset_y = -10
	self.offset_z = 0
	self.obstacle = 1
	self.w = 3
	self.h = 2
end	

CavePile = {}

function CavePile:event_init()
	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("cavepile.bmp")
	self.offset_x = 24
	self.offset_y = -12
	self.offset_z = 0
	self.obstacle = 1
	self.w = 3
	self.h = 5
end

function CavePile:event_activate(obj)
	if (picked_up_pick) then
		SeqControl:add_sequence({
			ActionExModeOn(),
			ActionConversation(conv.USE_PICKAXE),
			ActionFadeOutMap(100),
			ActionDestroyObject(self),
			ActionAddObject("CavePileTop", 16, 29),
			ActionAddObject("CavePileBottom", 16, 32),
			ActionFadeInMap(100),
			ActionConversation(conv.PICKAXE_WORKED),
			ActionExModeOff(),
		})
	else
		SeqControl:add_sequence({
			ActionConversation(conv.PILE_WONT_BUDGE),
		})
	end
end


-- Pick and howel
CavePick = {}

function CavePick:event_init()
	self.draw_mode = DM_MASKED
	self.bitmap = m_get_bitmap("cavepick.bmp")
	self.obstacle = 1
	self.offset_x = 0
	self.offset_y = -10
	self.offset_z = -10
end	

function CavePick:event_activate(obj)
	picked_up_pick = 1
	m_destroy_object(self)
		SeqControl:add_sequence({
			ActionConversation(conv.PICKUP_PICKAXE)
		})
end

