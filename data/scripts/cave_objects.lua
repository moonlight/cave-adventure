-- cave_objects.lua
-- Cave-specific objects
--

import("Decoration.lua")
import("lang.lua")


CaveWaterfallExit = Decoration:subclass
{
	name = "CaveWaterfallExit";

	defaultproperties = {
		animType = LinearAni,
		animSeq = extr_array(m_get_bitmap("cave_waterfall_exit.bmp"), 72, 48),
		tick_time = 10,

		convTable = {
			conv.NO_WAY_OUT,
			conv.NO_ESCAPE,
		},
	};
}


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
CavePileTop = Decoration:subclass
{
	name = "CavePileTop";

	defaultproperties = {
		draw_mode = DM_MASKED,
		bitmap = m_get_bitmap("rubble_t.bmp"),
		offset_x = 24,
		offset_y = 5,
		offset_z = 0,
		obstacle = 1,
		w = 3,
		h = 2,
	};
}

CavePileBottom = Decoration:subclass
{
	name = "CavePileBottom";

	defaultproperties = {
		draw_mode = DM_MASKED,
		bitmap = m_get_bitmap("rubble_b.bmp"),
		offset_x = 24,
		offset_y = -10,
		offset_z = 0,
		obstacle = 1,
		w = 3,
		h = 2,
	};
}


CavePile = Decoration:subclass
{
	name = "CavePile";

	event_activate = function(self, instigator)
		if (picked_up_pick) then
			ActionController:addSequence({
				ActionExModeOn(),
				ActionConversation(conv.USE_PICKAXE),
				ActionFadeOutMap(100),
				ActionDestroyObject(self),
				ActionAddObject(CavePileTop, 16, 29),
				ActionAddObject(CavePileBottom, 16, 32),
				ActionFadeInMap(100),
				ActionConversation(conv.PICKAXE_WORKED),
				ActionExModeOff(),
			})
		else
			ActionController:addSequence({
				ActionConversation(conv.PILE_WONT_BUDGE),
			})
		end
	end;

	defaultproperties = {
		draw_mode = DM_MASKED,
		bitmap = m_get_bitmap("cavepile.bmp"),
		offset_x = 24,
		offset_y = -12,
		offset_z = 0,
		obstacle = 1,
		w = 3,
		h = 5,
	};
}



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
	ActionController:addSequence({
		ActionConversation(conv.PICKUP_PICKAXE)
	})
end

