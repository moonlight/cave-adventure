--
-- Z (sleeping thingy)
--
Z = {}

function Z:event_init()
	inherit(self, BasicObject)
	inherit(self, FrameDurationAni)

	self:start_animation({
		{z_anim[1],  10},
		{z_anim[2],  1},
		{z_anim[3],  2},
		{z_anim[4],  2},
		{z_anim[5],  1},
		{z_anim[6],  1},
		{z_anim[7],  2},
		{z_anim[8],  2},
		{z_anim[9],  1},
		{z_anim[10], 1},
		{z_anim[11], 1},
	})
	self.animation_speed = 0.2

	--self.offset_y = -6
	self.tick_time = 1
	self.draw_mode = DM_ALPHA
end