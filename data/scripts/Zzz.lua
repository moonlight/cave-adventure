--
-- Z (sleeping thingy)
--

import("Decoration.lua")
import("AnimationFunctions.lua")


Zzz = Decoration:subclass
{
	name = "Z";

	init = function(self)
		animSeq = {
			{self.animBmps[1],  10},
			{self.animBmps[2],  1},
			{self.animBmps[3],  2},
			{self.animBmps[4],  2},
			{self.animBmps[5],  1},
			{self.animBmps[6],  1},
			{self.animBmps[7],  2},
			{self.animBmps[8],  2},
			{self.animBmps[9],  1},
			{self.animBmps[10], 1},
			{self.animBmps[11], 1},
		},

		Decoration.init(self)

		self.animation.animation_speed = 0.2
	end;

	defaultproperties = {
		animType = FrameDurationAni,
		animBmps = extr_array(m_get_bitmap("z.tga"), 24, 24),
		obstacle = 0,
		--offset_y = -6,

		tick_time = 1,
		draw_mode = DM_ALPHA,
	};
}
