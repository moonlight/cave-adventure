--
-- Cave-specific objects
--

import("Decoration.lua")


CaveWaterfallExit = Decoration:subclass
{
	name = "CaveWaterfallExit";

	defaultproperties = {
		bCenterOnTile = false,
		animType = LinearAnimation,
		animSeq = extr_array(m_get_bitmap("cave_waterfall_exit.bmp"), 72, 48),
		animSpeed = 1 / 10,
		convTableKeyword = "Escape",
	};
}


--
-- Top, Roof and Bottom, used for caves you can walk through
--

CaveTunnelTop = Decoration:subclass
{
	name = "CaveTunnelTop";

	defaultproperties = {
		draw_mode = DM_ALPHA,
		bitmap = m_get_bitmap("cave_entrance2.tga"),
		offset_z = 48,
		offset_y = 24,
		obstacle = 0,
	};
}

CaveRoof = Decoration:subclass
{
	name = "CaveRoof";

	defaultproperties = {
		draw_mode = DM_MASKED,
		bitmap = m_get_bitmap("cave_roof.bmp"),
		offset_z = 48,
		offset_y = 48,
		obstacle = 0,
	};
}

CaveTunnelBottom = Decoration:subclass
{
	name = "CaveTunnelBottom";

	defaultproperties = {
		draw_mode = DM_ALPHA,
		bitmap = m_get_bitmap("cave_entrance.tga"),
		offset_z = 48,
		offset_y = 28,
		obstacle = 0,
	};
}


-- Spider web

SpiderWeb = Decoration:subclass
{
	name = "SpiderWeb";
	defaultproperties = {
		draw_mode = DM_ALPHA,
		bitmap = m_get_bitmap("web.tga"),
		offset_y = 7,
		offset_x = 10,
	};
}

SpiderWeb2 = Decoration:subclass
{
	name = "SpiderWeb2";
	defaultproperties = {
		draw_mode = DM_ALPHA,
		bitmap = m_get_bitmap("web2.tga"),
		offset_y = 7,
		offset_x = -10,
	}
}


--
-- The horizontal bridge elements
--

CaveBridge1 = Decoration:subclass
{
	name = "CaveBridge1";

	defaultproperties = {
		draw_mode = DM_MASKED,
		bitmap = m_get_bitmap("cavebridge1.bmp"),
		offset_x = 0,
		offset_y = -10,
		offset_z = -10,
		obstacle = 0,
	};
}


CaveBridge2 = Decoration:subclass
{
	name = "CaveBridge2";

	defaultproperties = {
		draw_mode = DM_MASKED,
		bitmap = m_get_bitmap("cavebridge2.bmp"),
		offset_x = 0,
		offset_y = 0,
		offset_z = 0,
		obstacle = 0,
	};
}


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

	activatedBy = function(self, instigator)
		if (picked_up_pick) then
			ActionController:addSequence({
				ActionExModeOn(),
				ActionConversation(lang:getConv("USE_PICKAXE")),
				ActionFadeOutMap(100),
				ActionDestroyObject(self),
				ActionAddObject(CavePileTop, 16, 29),
				ActionAddObject(CavePileBottom, 16, 32),
				ActionFadeInMap(100),
				ActionConversation(lang:getConv("PICKAXE_WORKED")),
				ActionExModeOff(),
			})
		else
			ActionController:addSequence({
				ActionConversation(lang:getConv("PILE_WONT_BUDGE")),
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
		bCanActivate = true,
	};
}



-- Pick and howel
CavePick = Decoration:subclass
{
	name = "CavePick";

	activatedBy = function(self, obj)
		picked_up_pick = 1
		m_destroy_object(self)
		ActionController:addSequence({
			ActionConversation(lang:getConv("PICKUP_PICKAXE"))
		})
	end;

	defaultproperties = {
		draw_mode = DM_MASKED,
		bitmap = m_get_bitmap("cavepick.bmp"),
		obstacle = 1,
		offset_x = 0,
		offset_y = -10,
		offset_z = -10,
		bCanActivate = true,
	};
}
