-- An controller which makes its Pawn walk around randomly, scared, aggressive, neutral or moody...
--
-- Bodged by Hedde Bosman

import("Controller.lua")

SCARED = 1
NEUTRAL = 2
AGGRESSIVE = 3
MOODY = 4

AdvAIRandom = Controller:subclass
{
	name = "AdvAIRandom";

	init = function(self)
		self.waitTime = math.random(100) + 10
	end;

	-- == depending on this nature choose a target (to be scared of) ==-
	setTargetWithNature = function(self, nature, target)
		if ((nature == NEUTRAL) or (nature == AGGRESSIVE)) then
			self.target = target;
			self.scaring = nil;
		elseif (nature == SCARED) then
			self.target = nil;
			self.scaring = target;
		elseif (nature == MOODY) then
			self:setTargetWithNature(self.nature_tmp, target)
		else
			self:log("What am i? Who am i? How did i get here? What's that i'm hearing? Hmmm lets call it wind...")
		end;
	end;

	-- == -- == notifiers == -- == --
	-- 
	notifyBumpInto = function(self, obj)
		-- Pause for some time and choose another direction
		if (self.pawn.bAttacking == false) then
			self.waitTime = math.random(100) + 10
		end
	end;
	notifyWalkFinished = function(self)
                if (self.distanceToWalk <= 0 and self.pawn.bAttacking == false) then
		        -- Reached his goal, pause and choose new goal.
			if (self.target or self.scaring) then
				-- korte wachttijd, anders staat ie na elke tile even (te lang) stil
				self.waitTime = math.random(4) + 1
			else
				self.waitTime = math.random(100) + 2
			end;
		else
		        -- Walking to goal, keep walking.
		        self.distanceToWalk = self.distanceToWalk - 1
		        self.pawn:walk(self.pawn.dir)
		end;
	end;

	-- == do shizzle depending on nature, and possibly mood == --

	notifyHearNoise = function(self, loudness, noiseMaker)
		if (self.pawn:distanceTo(noiseMaker) < 8) then self.pawn.tick_time = 1; end;
		if (self.pawn:distanceTo(noiseMaker) >= 8) then self.pawn.tick_time = 150; end;
		if (noiseMaker and noiseMaker:instanceOf(Player)) then
			if (self.pawn.nature ~= NEUTRAL) then
				self:setTargetWithNature(self.pawn.nature, noiseMaker)
			end;
		end;
	end;
	notifyTakeDamage = function(self, damage, instigator, damageType, momentum, location)
		if (instigator and instigator:instanceOf(Player)) then
			self:setTargetWithNature(self.pawn.nature, instigator);
		end;
	end;
	
	-- check if we can go in 'dir'-ection ... if not, choose any other, but not 'notdir'
	goingDirection = function(self, dir, notdir)
		local dirs = self.pawn:freeTilesAround()
		for v in dirs do
		    if (v == dir) then
			return dir
		    end;
		end;
		for v in dirs do
		    if (v ~= notdir) then
			return v;
		    end;
		end;
		return dir
	end;

	-- timebom
	tick = function(self)
		if (self.pawn.bDead) then return end

		if (self.pawn.charging > 0) then self.pawn.charging = self.pawn.charging - 1 end
		
		if (self.waitTime > 0) then 
			self.waitTime = self.waitTime - 1;

			if (self.pawn.nature == MOODY) then
				-- this one is shifting moods... do new mood, and state how long it has that mood
				self.moodTime = self.moodTime -1
				if (self.moodTime <= 0) then
					self.target = nil
					self.scaring = nil
					self.moodTime = 500 + math.random(1000)
					self.nature_tmp = math.random(3)
				end;
			end;
			
			if (self.waitTime <= 0 and self.pawn.bAttacking == false) then
				-- Check for targets and their distances
				if (self.target) then
					playerDist = self.pawn:distanceTo(self.target)
				elseif (self.scaring) then
					-- bangmakerij
					playerDist = self.pawn:distanceTo(self.scaring)
				else
					playerDist = 100
				end;
			
				if (playerDist == 1 and self.target) then
					self.pawn.dir = self.pawn:directionTo(self.target)
					self.pawn:attack()
					self.waitTime = self.pawn.attackTime + self.pawn.chargeTime + 10
				else
					if (self.target or self.scaring) then
						-- direct loopafstand bij vijand of bangmaker
						self.distanceToWalk = 0
					else
						-- anders random loopafstand
						self.distanceToWalk = -1 + math.random(3)
					end;

					if (self.target and playerDist < 5) then
						-- hot persuit mode
						self.pawn.dir = self:goingDirection(self.pawn:directionTo(self.target), nil);
					elseif (self.scaring and playerDist < 15) then
						-- scared; will run in opposit direction
						local tmpdir = self.pawn:directionTo(self.scaring)
						self.pawn.dir = self:goingDirection(self:reverseDirection(tmpdir), tmpdir);
					else
						-- walk around
						self.scaring = nil;
						self.target = nil;
						self.pawn.dir = self.pawn:randomFreeTileAround()
					end;
					self.pawn:walk(self.pawn.dir)
				end;
			end
		end;
	end;

	defaultproperties = {
		tick_time = 0,
		waitTime = 20,
		distanceToWalk = 0,
		nature = NEUTRAL,
		nature_tmp = NEUTRAL,
		moodTime = 500,
		target = nil,
		scaring = nil,
	};
}
