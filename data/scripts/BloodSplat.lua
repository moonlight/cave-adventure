--
-- Some bloody splats
--

BloodSplat = Actor:subclass
{
	name = "BloodSplat";

	init = function(self)
		self:playAnim(LinearAnimation(self.animSeq))
	end;
	animEnd = function(self)
		self:destroy()
	end;

	defaultproperties = {
		animSeq = extr_array(m_get_bitmap("blood_splat.bmp"), 16, 16),
		tick_time = 7,
		bCenterBitmap = true,
	}
}

BloodSplatGreen = BloodSplat:subclass
{
	name = "BloodSplatGreen";
	defaultproperties = {
		animSeq = extr_array(m_get_bitmap("blood_splat_green.bmp"), 16, 16),
	}
}

BloodSplatYellow = BloodSplat:subclass
{
	name = "BloodSplatGreen";
	defaultproperties = {
		animSeq = extr_array(m_get_bitmap("blood_splat_yellow.bmp"), 16, 16),
	}
}
