-- radio.lua
-- The radio set, including the jumping speaker and pile of CDs.
-- By Bjørn Lindeijer

--
-- The radio with a randomly animated VU-meter.
--
Radio = {}

function Radio:event_init()
	inherit(self, BasicObject)
	inherit(self, RandomAni)
	self.draw_mode = DM_MASKED

	self:start_animation(radio_anim)
	self.tick_time = 10
end

function Radio:event_activate(instigator)
	local text_table = {
		{{"Frode", "Cool music."}},
		{{"Frode", "I like the Beach Boys's music."}},
		{{"Frode", "Yeah! Great soundsystem!"}},
	}

	repeat n = math.random(table.getn(text_table)) until (n ~= self.prev_random)
	self.prev_random = n

	write_conversation(text_table[n])
end


--
-- The jumping box, hilarious.
--
Jumping_Box = {}

function Jumping_Box:event_init()
	inherit(self, BasicObject)
	inherit(self, FrameDurationAni)

	self:start_animation({
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
	})
	self.animation_speed = 1.2

	self.offset_y = -6
	self.tick_time = 1
end


--
-- A pile of CDs with a clever remark on activation.
--
CDs = {}

function CDs:event_init()
	self.bitmap = m_get_bitmap("cds.tga")
	self.draw_mode = DM_ALPHA
end

function CDs:event_activate(instigator)
	write_conversation({{"Frode", "Let's see if there's another CD of the Village People..."}})
end