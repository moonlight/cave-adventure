--
-- The third cave map, with the boss.
--

import("Map.lua")

Cave3 = Map:subclass
{
	name = "Cave3";

	init = function(self)
		Map.init(self, "data/maps/cave3.map")

		self:spawn(Spring, 12, 12)

		-- Torches
		self:spawn(Torch, 30, 9)
		self:spawn(Torch, 40, 9)
		self:spawn(Torch, 30, 16)
		self:spawn(Torch, 40, 16)

		self:spawn(Torch, 8, 34)
		self:spawn(Torch, 79, 34)
		self:spawn(Torch, 64, 27)
		self:spawn(Torch, 95, 27)

		self:spawn(Torch, 33, 18)
		self:spawn(Torch, 33, 23)
		self:spawn(Torch, 33, 28)
		self:spawn(Torch, 33, 33)

		self:spawn(Torch, 37, 18)
		self:spawn(Torch, 37, 23)
		self:spawn(Torch, 37, 28)
		self:spawn(Torch, 37, 33)

		-- Cavemen

		obj = self:spawn(Caveman, 33, 20)
		obj.dir = DIR_RIGHT
		cavem1 = obj
		obj = self:spawn(Caveman, 33, 25)
		obj.dir = DIR_RIGHT
		cavem2 = obj
		obj = self:spawn(Caveman, 33, 30)
		obj.dir = DIR_RIGHT
		cavem3 = obj
		obj = self:spawn(Caveman, 37, 20)
		obj.dir = DIR_LEFT
		cavem4 = obj
		obj = self:spawn(Caveman, 37, 25)
		obj.dir = DIR_LEFT
		cavem5 = obj
		obj = self:spawn(Caveman, 37, 30)
		obj.dir = DIR_LEFT
		cavem6 = obj

		caveman_guard1 = self:spawn(EnemyCaveman, 80, 27)
		caveman_guard1.dir = DIR_RIGHT
		caveman_guard1:setState(AI_WAITING)
		caveman_guard2 = self:spawn(EnemyCaveman, 84, 27)
		caveman_guard2.dir = DIR_LEFT
		caveman_guard2:setState(AI_WAITING)
		caveman_guard3 = self:spawn(EnemyCaveman, 79, 27)
		caveman_guard3.dir = DIR_DOWN
		caveman_guard3:setState(AI_WAITING)
		caveman_guard4 = self:spawn(EnemyCaveman, 85, 27)
		caveman_guard4.dir = DIR_DOWN
		caveman_guard4:setState(AI_WAITING)

		-- Fences in prison

		self:spawn(FenceL,  66, 25)
		self:spawn(Fence1,  67, 25)
		self:spawn(FenceG2, 68, 25)
		self:spawn(Fence2,  69, 25)
		self:spawn(FenceR,  70, 25)
		
		self:spawn(FenceL,  73, 25)
		self:spawn(Fence2,  74, 25)
		self:spawn(FenceG2, 75, 25)
		self:spawn(Fence1,  76, 25)
		self:spawn(FenceR,  77, 25)

		self:spawn(FenceL,  80, 25)
		self:spawn(Fence2,  81, 25)
		self:spawn(FenceG,  82, 25)
		self:spawn(Fence2,  83, 25)
		self:spawn(FenceR,  84, 25)

		self:spawn(FenceL,  87, 25)
		self:spawn(Fence1,  88, 25)
		self:spawn(FenceG2, 89, 25)
		self:spawn(Fence1,  90, 25)
		self:spawn(FenceR,  91, 25)
		
		self:spawn(CaveTunnelTop, 35, 40)

		static_boss = self:spawn(CaveBoss, 35, 11)

		self:spawn(CaveNoticeStrong, 68, 34)
		obj = self:spawn(BossFightTrigger, 35, 12)
		obj.offset_y = -6
		boss_block = self:spawn(BossBlock, 33, 18)
	end;
}
