-- boss.lua
-- The big fat green boss

import("Character.lua")

--
-- The behaving boss with normal sit-in-chair mode
--

CaveBoss = Character:subclass
{
	name = "Boss";

	defaultproperties = {
		draw_mode = DM_MASKED,
		speed = 3,
		bitmap = m_get_bitmap("boss_1.bmp"),
	};
}


--
-- The super evil, hovering, boss
--

EnemyBoss = Character:subclass
{
	name = "EnemyBoss";

	init = function(self)
		inherit(self, BasicChar)
		inherit(self, BossAI)
		self:event_init(self)

		-- Set our own common options
		self.attack_range = 2 -- nvt
		self.attack_min_damage = 0
		self.attack_max_damage = 0

		self.draw_mode = DM_MASKED
		self.speed = 3
		self.bitmap = m_get_bitmap("boss_1.bmp")
	end;

	attack = function(self, obj)
		--ShootPoison(self, obj)
	end;

	died = function(self)
		self.animation = nil
		--self.bitmap = m_get_bitmap("spider2_dead.bmp")


		--
		-- BIG BOSS DIES SEQUENCE ADDED HERE!!!
		--

		ActionController:addSequence({
			ActionAddSequence({
				ActionSetVariable(self, "draw_mode", DM_TRANS),
				ActionSetVariable(self, "goal_z", 0),
				ActionTweenVariable(self, "alpha", 25, 255),
			}),
			ActionWait(50),
			ActionConversation(lang:getConv("BOSS_BEATEN_1")),
			ActionExModeOn(),
			ActionWait(25),
			ActionTweenVariable(self, "alpha", 200, 0),
			ActionDestroyObject(self),
			ActionWait(25),
			ActionChangeDirection(m_get_player(), DIR_DOWN),
			ActionConversation(lang:getConv("BOSS_BEATEN_2")),
			ActionFadeOutMap(100),
			ActionSetPosition(m_get_player(), 35, 11, DIR_DOWN),
			ActionSetVariable(m_get_player(), "tick_time", 0), -- DISABLELNG PLAYER TICK!
			ActionChangeBitmap(m_get_player(), m_get_bitmap("frode_sit1.tga")),
			ActionSetPosition(cavem1, 33, 11, DIR_RIGHT),
			ActionSetPosition(cavem2, 37, 11, DIR_LEFT),
			ActionSetPosition(cavem3, 34, 13, DIR_UP),
			ActionSetPosition(cavem4, 35, 14, DIR_UP),
			ActionSetPosition(cavem5, 36, 13, DIR_UP),
			ActionSetPosition(cavem6, 35, 13, DIR_UP),
			ActionFadeInMap(100),
			ActionConversation(lang:getConv("BOSS_BEATEN_3")),
			ActionFadeOutMap(300),
			ActionWait(100),
			ActionQuitGame(),
		})
	end;
}



--
-- The trigger that sets the boss on the loose
--

BossFightTrigger = Actor:subclass
{
	name = "BossFightTrigger";

	event_stand_on = function(self, obj)
		local player = m_get_player()

		if (player == obj and not boss_triggered) then
			boss_triggered = 1

			ActionController:addSequence({
				ActionExModeOn(),
				ActionSetVariable(camera, "target", self),
				ActionChangeDirection(player, DIR_UP),
				ActionConversation(lang:getConv("BOSS_AFTER_PRISON")),
				ActionAddObject("EnemyBoss", static_boss.x, static_boss.y),
				ActionDestroyObject(static_boss),
				ActionSetVariable(boss_block, "obstacle", 1),
				ActionExModeOff(),
			})
		end
	end;

	defaultproperties = {
		obstacle = 0,
		w = 1,
		h = 1,
	};
}



--
-- The boss shadow
--

BossShadow = Shadow:subclass
{
	name = "BossShadow";
	
	preRender = function(self)
		Shadow.preRender(self)
		if (self.owner) then
			self.alpha = self.owner.alpha * 0.5
		end
	end;

	defaultproperties = {
		bitmap = m_get_bitmap("boss_shadow.bmp"),
		draw_mode = DM_MULTIPLY,
	};
}


--
-- BossBlock
--

BossBlock = Actor:subclass
{
	name = "BossBlock";

	defaultproperties = {
		w = 5,
		h = 1,
		obstacle = 0, -- Not an obstacle permanently, used by scripts
	};
}
