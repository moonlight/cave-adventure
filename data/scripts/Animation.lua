-- Animation.lua
-- All animation schemes should inherit from this basic structure, exposing
-- start, stop and update features and making the bitmap accesible through
-- a bitmap member variable.
-- By Bjørn Lindeijer

import("Object.lua")


Animation = Object:subclass
{
	name = "Animation";

	start = function(self, animation)
		self:start_animation(animation)
	end;

	stop = function(self)
		self:stop_animation()
	end;

	update = function(self)
		self:update_bitmap()
	end;
}




-- BASIC LINEAR ANIMATION
-- An array of bitmaps is looped through at a certain speed.
--
LinearAni = Animation:subclass
{
	name = "LinearAni";

	start_animation = function(self, animation)
		self.animation_count = 1
		self.animation = animation
		self:update_bitmap()
	end;

	stop_animation = function(self)
		self.animation = nil
	end;

	update_bitmap = function(self)
		local nr = table.getn(self.animation)

		if (self.animation and table.getn(self.animation) > 0) then
			self.bitmap = self.animation[self.animation_count]
		end

		self.animation_count = self.animation_count + self.animation_speed

		if (self.animation and self.animation_count > nr and nr > 0) then
			self.animation_count = 1

			if (self.animation_finished) then
				self:animation_finished()
			end
		end
	end;

	event_tick = function(self)
		self:update_bitmap()
	end;

	defaultproperties = {
		animation = {},
		animation_count = 1,
		animation_speed = 1,
	};
	animation = {};
	animation_count = 1;
	animation_speed = 1;
}


-- RANDOM FRAME ANIMATION
-- Every tick a random bitmap is chosen.
--
RandomAni = Animation:subclass
{
	name = "RandomAni";

	start_animation = function(self, animation)
		self.animation = animation
		self:update_bitmap()
	end;

	stop_animation = function(self)
		self.animation = nil
	end;

	update_bitmap = function(self)
		if (self.animation) then
			local nr = table.getn(self.animation)
			if (nr == 1) then
				self.bitmap = self.animation[1]
			elseif (nr > 1) then
				repeat n = math.random(nr) until n ~= self.prev_animation_frame
				self.prev_animation_frame = n
				self.bitmap = self.animation[n]
			end
		end
	end;

	event_tick = function(self)
		self:update_bitmap()
	end;

	defaultproperties = {
		animation = {},
		prev_animation_frame = 0,
	};
	animation = {};
	prev_animation_frame = 0;
}



-- FRAMES WITH DURATION ANIMATION
-- A more advanced animation system, in which you have to specify how long
-- each frame is displayed.
--
FrameDurationAni = Animation:subclass
{
	name = "FrameDurationAni";

	start_animation = function(self, animation)
		self.animation = animation
		self.animation_count = 1
		self.frame_count = 1
		self:update_bitmap()
	end;

	stop_animation = function(self)
		self.animation = nil
	end;

	update_bitmap = function(self)
		if (self.animation and table.getn(self.animation) > 0) then
			while (self.animation and table.getn(self.animation) > 0 and self.frame_count > self.animation[self.animation_count][2]) do
				self.frame_count = self.frame_count - self.animation[self.animation_count][2]
				self.animation_count = self.animation_count + 1

				if (self.animation_count > table.getn(self.animation)) then
					self.animation_count = 1

					if (self.animation_finished) then
						self:animation_finished()
					end
				end
			end

			if (self.animation and table.getn(self.animation) > 0) then
				self.bitmap = self.animation[self.animation_count][1]
			end

			self.frame_count = self.frame_count + self.animation_speed
		end
	end;

	event_tick = function(self)
		self:update_bitmap()
	end;


	defaultproperties = {
		animation = {},
		animation_count = 1,
		animation_speed = 1,
		frame_count = 1,
	};
	animation = {};
	animation_count = 1;
	animation_speed = 1;
	frame_count = 1;
}



-- BASIC CHARACTER ANIMATION
-- Switches leg every tile and adapts to character direction.
--
BasicCharAni = Animation:subclass
{
	name = "BasicCharAni";

	start_animation = function(self, animation)
		self.animation = animation
		self:update_bitmap()
	end;

	update_bitmap = function(self)
		local ani = self.animation
		if (ani) then
			if (self.attacking == 1) then
				self.bitmap = ani[self.dir + 1 + 3 * 4]
			else
				if (self.walking == 0 or self.walking < 50) then
					self.bitmap = ani[self.dir + 1]
				else
					self.bitmap = ani[self.dir + 1 + (self.leg_used + 1) * 4]
				end
			end
		end
	end;

	event_walk_start = function(self)
		self.leg_used = 1 - self.leg_used
		--self.tick_time = 1
	end;

	event_walk_finished = function(self)
		self:update_bitmap()
		--self.tick_time = 0
	end;

	event_dir_change = function(self)
		self:update_bitmap()
	end;

	event_tick = function(self)
		self:update_bitmap()
	end;


	defaultproperties = {
		leg_used = 0,
		tick_time = 1,
		walking = 0,
	};
	leg_used = 0;
	tick_time = 1;
	walking = 0;
}



