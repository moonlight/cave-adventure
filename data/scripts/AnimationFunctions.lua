--
-- Animation functions to help extracting animations from bitmaps
--



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
