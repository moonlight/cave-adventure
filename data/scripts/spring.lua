-- Spring.lua
-- The spring by Frode

Spring = {}

function Spring:event_init()
	inherit(self, BasicObject)
	inherit(self, LinearAni)

	self:start_animation(spring_anim)
	self.tick_time = 8
	self.draw_mode = DM_MASKED
	self.w = 2
	self.h = 1
	self.offset_x = 12

end

function Spring:event_activate(instigator)
	local text_table = {
		conv.REFRESHING,
		conv.COULD_USE_THAT,
		conv.MUCH_BETTER,
	}
	
	repeat n = random(getn(text_table)) until (n ~= self.prev_random)
	self.prev_random = n

	write_conversation(text_table[n])

	if (player.health < player.maxHealth) then
		SeqControl:add_sequence({
			ActionTweenVariable(player, "health", 2*(player.maxHealth - player.health), player.maxHealth),
		})
	end
end