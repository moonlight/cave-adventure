-- ani_types.lua
-- Here we define some basic character animation shemes that can be used
-- by objects.
-- By Bjørn Lindeijer


-- BASIC LINEAR ANIMATION
-- An array of bitmaps is looped through at a certain speed.
--
LinearAni = {
	animation = {},
	animation_count = 1,
	animation_speed = 1,
}

function LinearAni:start_animation(animation)
	self.animation_count = 1
	self.animation = animation
	self:update_bitmap()
end
function LinearAni:stop_animation()
	self.animation = nil
end
function LinearAni:update_bitmap()
	local nr = getn(self.animation)

	if (self.animation and getn(self.animation) > 0) then
		self.bitmap = self.animation[self.animation_count]
	end

	self.animation_count = self.animation_count + self.animation_speed

	if (self.animation and self.animation_count > nr and nr > 0) then
		self.animation_count = 1

		if (self.animation_finished) then
			self:animation_finished()
		end
	end
end
function LinearAni:event_tick()
	self:update_bitmap()
end


-- RANDOM FRAME ANIMATION
-- Every tick a random bitmap is chosen.
--
RandomAni = {
	animation = {},
	prev_animation_frame = 0,
}

function RandomAni:start_animation(animation)
	self.animation = animation
	self:update_bitmap()
end
function RandomAni:stop_animation()
	self.animation = nil
end
function RandomAni:update_bitmap()
	if (self.animation) then
		local nr = getn(self.animation)
		if (nr == 1) then
			self.bitmap = self.animation[1]
		elseif (nr > 1) then
			repeat n = random(nr) until n ~= self.prev_animation_frame
			self.prev_animation_frame = n
			self.bitmap = self.animation[n]
		end
	end
end
function RandomAni:event_tick()
	self:update_bitmap()
end


-- FRAMES WITH DURATION ANIMATION
-- A more advanced animation system, in which you have to specify how long
-- each frame is displayed.
--
FrameDurationAni = {
	animation = {},
	animation_count = 1,
	animation_speed = 1,
	frame_count = 1
}

function FrameDurationAni:start_animation(animation)
	self.animation = animation
	self.animation_count = 1
	self.frame_count = 1
	self:update_bitmap()
end
function FrameDurationAni:stop_animation()
	self.animation = nil
end
function FrameDurationAni:update_bitmap()
	if (self.animation and getn(self.animation) > 0) then
		while (self.animation and getn(self.animation) > 0 and self.frame_count > self.animation[self.animation_count][2]) do
			self.frame_count = self.frame_count - self.animation[self.animation_count][2]
			self.animation_count = self.animation_count + 1

			if (self.animation_count > getn(self.animation)) then
				self.animation_count = 1

				if (self.animation_finished) then
					self:animation_finished()
				end
			end
		end

		if (self.animation and getn(self.animation) > 0) then
			self.bitmap = self.animation[self.animation_count][1]
		end

		self.frame_count = self.frame_count + self.animation_speed
	end
end
function FrameDurationAni:event_tick()
	self:update_bitmap()
end


-- BASIC CHARACTER ANIMATION
-- Switches leg every tile and adapts to character direction.
--
BasicCharAni = {leg_used = 0, tick_time = 1}

function BasicCharAni:start_animation(animation)
	self.animation = animation
	self:update_bitmap()
end
function BasicCharAni:update_bitmap()
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
end
function BasicCharAni:event_walk_start()
	self.leg_used = 1 - self.leg_used
	--self.tick_time = 1
end
function BasicCharAni:event_walk_finished()
	self:update_bitmap()
	--self.tick_time = 0
end
function BasicCharAni:event_dir_change()
	self:update_bitmap()
end
function BasicCharAni:event_tick()
	self:update_bitmap()
end


