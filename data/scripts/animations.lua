-- animations.lua
-- Animation definitions and functions to help extracting animations from bitmaps
--


--
-- This function contains adds some animations using the helper functions below.
-- It is called from game.lua
--
function add_animations()
	-- Characteranimations
	frode_anim   = extr_char_anim(m_get_bitmap("frode.tga"))
	caveman_anim = extr_char_anim(m_get_bitmap("caveman.bmp"))
	spider_anim  = extr_char_anim(m_get_bitmap("spider.bmp"), 24, 24)
	spider2_anim  = extr_char_anim(m_get_bitmap("spider2.bmp"), 24, 24)
	spider3_anim  = extr_char_anim(m_get_bitmap("spider3.bmp"), 24, 24)
	spider_small_anim  = extr_char_anim(m_get_bitmap("spider_small.bmp"), 16, 16)
	caveman_slave_anim = extr_char_anim(m_get_bitmap("caveman_slave.bmp"))
	rat_anim           = extr_char_anim(m_get_bitmap("rat.bmp"), 16, 16)

	player_anim = frode_anim

	-- Other animations
	z_anim = extr_array(m_get_bitmap("z.tga"), 24, 24)
	blood_splat_anim = extr_array(m_get_bitmap("blood_splat.bmp"), 16, 16)
	blood_splat_green_anim = extr_array(m_get_bitmap("blood_splat_green.bmp"), 16, 16)
	blood_splat_yellow_anim = extr_array(m_get_bitmap("blood_splat_yellow.bmp"), 16, 16)
end


--
-- Creates subbitmaps and puts them in an array in the following structure:
--
-- {u1, l1, r1, d1,
--  u2, l2, r2, d2,
--  u3, l3, r3, d3,
--  ua, la, ra, da}
--
-- Expecting the following bitmap structure:
--
-- {d1, d2, d3, da,
--  u1, u2, u3, ua,
--  r1, r2, r3, ra,
--  l1, l2, l3, la}
--
function extr_char_anim(bm, w, h)
	-- Function shortcut
	local csb = m_create_sub_bitmap

	if (not bm) then m_message("extr_char_anim(): no bitmap!"); return; end
	if (not w) then w = 24 end
	if (not h) then h = 48 end

	return {
		csb(bm, 0,   h, w, h), csb(bm, 0,   h*3, w, h), csb(bm, 0,   h*2, w, h), csb(bm, 0,   0, w, h),
		csb(bm, w,   h, w, h), csb(bm, w,   h*3, w, h), csb(bm, w,   h*2, w, h), csb(bm, w,   0, w, h),
		csb(bm, w*2, h, w, h), csb(bm, w*2, h*3, w, h), csb(bm, w*2, h*2, w, h), csb(bm, w*2, 0, w, h),
		csb(bm, w*3, h, w, h), csb(bm, w*3, h*3, w, h), csb(bm, w*3, h*2, w, h), csb(bm, w*3, 0, w, h),
	}
end

--
-- Creates an array of subbitmaps from a given bitmap and given the size
-- of each individual frame. Frames are extracted from the bitmap like:
--
--   {1, 2, 3, 4,
--    5, 6, 7, 8}
--
function extr_array(bm, w, h, spacing)
	if (not bm) then m_message("extr_array(): no bitmap!"); return; end
	
	local bw, bh = m_bitmap_size(bm)
	local bm_array = {}

	if (not w) then w = bw end
	if (not h) then h = bh end
	if (not spacing) then spacing = 0 end

	for y = 0, (bh / h) - 1 do
		for x = 0, (bw / w) - 1 do
			table.insert(bm_array, m_create_sub_bitmap(bm, x*(w+spacing), y*(h+spacing), w, h))
		end
	end

	return bm_array
end
