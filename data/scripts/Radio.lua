--
-- The radio set, including the jumping speaker and pile of CDs.
-- By Bjorn Lindeijer

import("Decoration.lua")
import("Animation.lua")


--
-- The radio with a randomly animated VU-meter.
--

Radio = Decoration:subclass
{
	name = "Radio";

	defaultproperties = {
		tick_time = 10,
		animType = RandomAnimation,
		animSeq = extr_array(m_get_bitmap("radio.bmp"), 17, 23),
		convTableKeyword = "Radio",
	}
}



--
-- The jumping box, hilarious.
--

JumpingBox = Decoration:subclass
{
	name = "JumpingBox";

	defaultproperties = {
		animType = FrameDurationAnimation,
		animSeq = {
			{m_get_bitmap("box1.bmp"), 1},
			{m_get_bitmap("box2.bmp"), 2},
			{m_get_bitmap("box3.bmp"), 3},
			{m_get_bitmap("box4.bmp"), 4},
			{m_get_bitmap("box5.bmp"), 5},
			{m_get_bitmap("box6.bmp"), 7},
			{m_get_bitmap("box7.bmp"), 15},
			{m_get_bitmap("box6.bmp"), 7},
			{m_get_bitmap("box5.bmp"), 5},
			{m_get_bitmap("box4.bmp"), 4},
			{m_get_bitmap("box3.bmp"), 3},
			{m_get_bitmap("box2.bmp"), 2},
			{m_get_bitmap("box1.bmp"), 1},
			{m_get_bitmap("box8.bmp"), 6},
			{m_get_bitmap("box9.bmp"), 10},
			{m_get_bitmap("box8.bmp"), 6},
		},
		animSpeed = 1.2,
		offset_y = -6,
	}
}


--
-- A pile of CDs with a clever remark on activation.
--

CDs = Decoration:subclass
{
	name = "CDs";

	defaultproperties = {
		bitmap = m_get_bitmap("cds.tga"),
		draw_mode = DM_ALPHA,
		convTableKeyword = "CDs",
	}
}
