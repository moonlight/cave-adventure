-- seq_actions.lua
--
-- In this file we define the combat controller.
--
-- By Bjørn Lindeijer

CC_DISABLED    = 0
CC_PLAYER_TURN = 1
CC_STARTING    = 2
CC_SEQUENCING  = 3


CombatControl = {
	enemies = {},
	friends = {},
	currEnemy = 0,
	currFriend = 0,
	greenDots = {},
	redCircles = {},
}

function CombatControl:init()
	self.state = CC_DISABLED
end

function CombatControl:update()
end

function CombatControl:keypress(key)
	local player = m_get_player()

	if (self.state == CC_PLAYER_TURN) then

		local prevX, prevY = player.x, player.y


		if (key == "right") then
			self:setState(CC_SEQUENCING)
			SeqControl:add_sequence({
				ActionWalk(player, DIR_RIGHT, 1, 1),
				ActionSetState(self, CC_PLAYER_TURN),
			})
		end
		if (key == "left") then
			self:setState(CC_SEQUENCING)
			SeqControl:add_sequence({
				ActionWalk(player, DIR_LEFT, 1, 1),
				ActionSetState(self, CC_PLAYER_TURN),
			})
		end
		if (key == "up") then
			self:setState(CC_SEQUENCING)
			SeqControl:add_sequence({
				ActionWalk(player, DIR_UP, 1, 1),
				ActionSetState(self, CC_PLAYER_TURN),
			})
		end
		if (key == "down") then
			self:setState(CC_SEQUENCING)
			SeqControl:add_sequence({
				ActionWalk(player, DIR_DOWN, 1, 1),
				ActionSetState(self, CC_PLAYER_TURN),
			})
		end

	elseif (self.state ~= CC_DISABLED) then

		-- Get rid of remaining red circles and green dots
		for i = 1, table.getn(self.redCircles) do
			m_destroy_object(self.redCircles[i])
		end
		for i = 1, table.getn(self.greenDots) do
			m_destroy_object(self.greenDots[i])
		end

		-- Get rid of the enemies
		for i = 1, table.getn(self.enemies) do
			m_destroy_object(self.enemies[i])
		end

		self:setState(CC_DISABLED)

	end
end

function CombatControl:draw()
	if (self.state ~= CC_DISABLED) then
		m_set_cursor(10,10)
		m_set_color(255,0,0)
		m_draw_text("Player health: "..player.health)
	end
end

function CombatControl:setState(state)
	self:endState()
	self.state = state
	self:beginState()
end

function CombatControl:beginState()
	if (self.state == CC_DISABLED) then
		m_set_ex_mode(self.prevExMode)
	end
end

function CombatControl:endState()
	if (self.state == CC_DISABLED) then
		self.prevExMode = m_set_ex_mode(1)
	end
end


function CombatControl:startCombat(friends, enemies)
	self.enemies = enemies
	self.friends = friends
	self:setState(CC_STARTING)

	-- Create red circles for all enemies
	self.redCircles = {}
	for i = 1, table.getn(self.enemies) do
		local circle = m_add_object(self.enemies[i].x, self.enemies[i].y, "CombatCircleRed")
		circle.offset_x = circle.offset_x + self.enemies[i].offset_x
		circle.offset_y = circle.offset_y + self.enemies[i].offset_y
		table.insert(self.redCircles, circle)
	end

	self:setState(CC_PLAYER_TURN)

	-- Create green dots to show where the player can walk
	player.stepsLeft = player.speed / 2

	self.greenDots = {}
	for x = player.x - player.speed, player.x + player.speed do
		for y = player.y - player.speed, player.y + player.speed do
			if (math.abs(player.x - x) + math.abs(player.y - y) <= (player.stepsLeft) and not (x == player.x and y == player.y)) then
				local dot = m_add_object(x, y, "CombatGreenDot")
				table.insert(self.greenDots, dot)
			end
		end
	end
end



-- The red circle below enemies
CombatGreenDot = {}
function CombatGreenDot:event_init()
	self.bitmap = m_get_bitmap("green_dot.tga")
	self.draw_mode = DM_ALPHA
	self.offset_y = -13
	self.offset_z = -5
	--self.tick = 1
end
--function CombatCircleRed:event_tick()
--	self.
--end

-- The green dot showing to where the player can walk
CombatCircleRed = {}
function CombatCircleRed:event_init()
	self.bitmap = m_get_bitmap("red_circle.tga")
	self.draw_mode = DM_ALPHA
	self.offset_y = -15
	self.offset_z = -20
end



--
-- Additional actions used in combat sequences.
--





--
-- A testing case.
--

TestStartCombat = {}

function TestStartCombat:init()
	self.w = 1
	self.h = 1
	self.obstacle = 0
end

function TestStartCombat:event_stand_on(obj)
	m_message("Stand on called");
	if (obj == player) then
		m_message("It's the player, starting combat");
		local goblins = {}
		local goblin
		goblin = m_add_object(self.x + 2, self.y + 1, "Goblin")
		goblin.dir = DIR_LEFT
		table.insert(goblins, goblin)
		goblin = m_add_object(self.x + 3, self.y + 2, "Goblin")
		goblin.dir = DIR_LEFT
		table.insert(goblins, goblin)
		goblin = m_add_object(self.x + 5, self.y, "Goblin")
		goblin.dir = DIR_LEFT
		table.insert(goblins, goblin)
		CombatControl:startCombat(goblins)
	end
end