--
-- This file contains the conversation windows class.
--
-- By Bjorn Lindeijer

import("Interaction.lua")



-- Receives a single string and returns array of tokens.
-- Ex: "Hello world!" -> {"Hello", "world!"}
tokenize = function(str)
	local tokens = {}
	local str_len = string.len(str)
	local start = 1

	while (start < str_len) do
		from, to, token = string.find(str, "%s?([^%s]*)", start)
		start = to + 1
		table.insert(tokens, token)
	end

	return tokens
end

detokenize = function(tokens)
	token_cnt = table.getn(tokens)

	if (token_cnt > 0) then
		local string = tokens[1]
		local n = 2

		while (n <= token_cnt) do
			string = string.." "..tokens[n]
			n = n + 1
		end

		return string
	else
		return ""
	end
end



CB_CLOSED    = 0
CB_READY     = 1
CB_WRITING   = 2
CB_SCROLLING = 3
CB_WAITING   = 4
CB_SCALING   = 5

ConversationWindow = Interaction:subclass
{
	name = "ConversationWindow";

	init = function(self)
		-- Get and set some sizes
		self.font = "font_sansserif8.pcx"
		m_set_font(self.font)
		self.space_width, self.line_height = m_text_size(" ")
		local w, h = m_screen_size()
		self.x = w / 4
		self.y = h - h / 4
		self.w = w / 2
		self.h = h / 2 - h / 3 + 5 - 2
		self.nr_lines = math.floor(self.h / self.line_height)
	end;

	write_line = function(self, string)
		table.insert(self.lines_todo, string)
		if (self.state == CB_CLOSED) then
			self.state = CB_SCALING
			ActionController:addSequence{
				ActionExModeOn(),
				ActionTweenVariable(self, "width", self.appear_time, 1),
				ActionTweenVariable(self, "height", self.appear_time, 1),
				ActionSetVariable(self, "state", CB_READY),
			}

			-- grab control over the player
			--m_set_ex_mode(1)
			--self.state = CB_READY
		end
	end;

	tick = function(self)
		if (self.state == CB_CLOSED) then
			return

		elseif (self.state == CB_READY and table.getn(self.lines_todo) > 0) then
			if (table.getn(self.lines) < self.nr_lines) then
				-- There is space, start writing the line.

				-- We need the correct font set when calculating how big the text is
				m_set_font(self.font)

				local tokens = tokenize(self.lines_todo[1])
				local new_line = tokens[1]
				table.remove(tokens, 1)

				while (table.getn(tokens) > 0 and m_text_size(new_line.." "..tokens[1]) < self.w) do
					new_line = new_line.." "..tokens[1]
					table.remove(tokens, 1)
				end

				-- Continue indicates if writing should continue after this line
				-- or if it should show a blinking square (end of sentence)
				if (table.getn(tokens) > 0) then
					self.continue = 1
					self.lines_todo[1] = detokenize(tokens)
				else
					self.continue = nil
					table.remove(self.lines_todo, 1)
				end

				table.insert(self.lines, new_line)
				self.curr_char = 1
				self.state = CB_WRITING
			else
				-- No line left, scroll up two lines.
				if (self.continue) then
					self:set_state(CB_WAITING)
				else
					self.state = CB_SCROLLING
				end
			end

		elseif (self.state == CB_READY) then
			-- Ready and no lines left todo
			ActionController:addSequence{
				ActionSetVariable(self, "state", CB_SCALING),
				ActionTweenVariable(self, "height", self.appear_time, 0),
				ActionTweenVariable(self, "width", self.appear_time, 0),
				ActionSetVariable(self, "state", CB_CLOSED),
				ActionExModeOff(),
			}

			--self.state = CB_CLOSED
			-- return control to the player
			--m_set_ex_mode(0)

		elseif (self.state == CB_SCROLLING) then
			if (self.scroll < (self.nr_lines - 1) * self.line_height) then
				self.scroll = self.scroll + 1
			else
				for n = 1,(self.nr_lines - 1) do
					table.remove(self.lines, 1)
				end

				self.scroll = 0
				self.state = CB_READY
			end

		elseif (self.state == CB_WRITING) then
			local current_string = self.lines[table.getn(self.lines)]
			local length = string.len(current_string)

			if (self.curr_char < length) then
				self.curr_char = self.curr_char + 0.5
			else
				-- This line has finished, either wait for key or continue
				-- with next line.
				if (self.continue) then
					self.state = CB_READY
				else
					self:set_state(CB_WAITING)
				end
			end

		elseif (self.state == CB_WAITING) then
			if (self.blink == 1) then
				-- Set appropriate blinking bitmap
				if (self.blink_bitmap) then
					self.blink_bitmap = nil
				else
					if (self.continue) then
						self.blink_bitmap = m_get_bitmap("arrow.bmp")
					else
						self.blink_bitmap = m_get_bitmap("square.bmp")
					end
				end
			end
			self.blink = self.blink + 1
			if (self.blink > 20) then self.blink = 1 end
		end
	end;

	keyType = function(self, key)
		if (key == "action" and self.state == CB_WAITING) then
			if (self.continue) then
				-- Scroll up
				self.state = CB_SCROLLING
			else
				self.state = CB_READY
			end
			return true
		end
		return false
	end;

	postRender = function(self, canvas)
		if (self.state == CB_CLOSED) then return end

		local screen_w, screen_h = m_screen_size()
		m_set_font(self.font)

		if (self.state ~= CB_SCALING) then
			-- Draw the shadow of the text
			m_set_clip(self.x, self.y, self.x + self.w - 1, self.y + self.h - 1)
			for n = 1, table.getn(self.lines) do
				m_set_color(0, 0, 0)
				m_set_cursor(self.x + 1, self.y + (n - 1) * self.line_height - self.scroll + 1)
				if (n == table.getn(self.lines)) then
					m_draw_text(string.sub(self.lines[n], 1, self.curr_char))
				else
					m_draw_text(self.lines[n])
				end
			end
		end

		-- Draw the box
		m_set_clip(0, 0, screen_w - 1, screen_h - 1)
		guiTheme:drawBox(
			(self.x + self.w / 2) - (self.w * self.width) / 2 - 4,
			(self.y + self.h / 2) - (self.h * self.height) / 2 - 4,
			self.w * self.width + 8,
			self.h * self.height + 8
		)

		if (self.state ~= CB_SCALING) then
			-- Draw the blinking icon
			if (self.state == CB_WAITING and self.blink_bitmap) then
				local w, h = m_bitmap_size(self.blink_bitmap)
				m_set_cursor(self.x + self.w - w, self.y + self.h - h)
				canvas:drawIcon(self.blink_bitmap, 1)
			end

			-- Draw the lines of text
			m_set_clip(self.x, self.y, self.x + self.w - 1, self.y + self.h - 1)
			for n = 1, table.getn(self.lines) do
				m_set_color(guiTheme:getTextColor())
				m_set_cursor(self.x, self.y + (n - 1) * self.line_height - self.scroll)
				if (n == table.getn(self.lines)) then
					m_draw_text(string.sub(self.lines[n], 1, self.curr_char))
				else
					m_draw_text(self.lines[n])
				end
			end
		end
		local w, h = m_screen_size()
		m_set_clip(0, 0, w - 1, h - 1)
	end;

	set_state = function(self, state)
		self.state = state

		if (self.state == CB_WAITING) then
			self.blink = 2
			if (self.continue) then
				self.blink_bitmap = m_get_bitmap("arrow.bmp")
			else
				self.blink_bitmap = m_get_bitmap("square.bmp")
			end
		end
	end;


	defaultproperties = {
		bRequiresTick = true,

		lines = {},
		lines_todo = {},
		state = CB_CLOSED,
		scroll = 0,
		curr_char = 1,
		continue = nil,
		blink = 1,
		width = 0,
		height = 0,
		appear_time = 15,
	};
}
