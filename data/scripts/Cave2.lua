--
-- The second cave map
--

import("Map.lua")

Cave2 = Map:subclass
{
	name = "Cave2";

	init = function(self)
		Map.init(self, "data/maps/cave2.map")

		self:spawn(Spring, 44, 7)
		self:spawn(Spring, 6, 42)
		
		-- Spider webs
		self:spawn(SpiderWeb, 19, 7)
		self:spawn(SpiderWeb, 1, 45)
		self:spawn(SpiderWeb, 30, 49)
		self:spawn(SpiderWeb, 43, 6)

		self:spawn(SpiderWeb2, 7, 7)
		self:spawn(SpiderWeb2, 32, 27)
		self:spawn(SpiderWeb2, 61, 18)
		
		-- Torches
		self:spawn(Torch, 6, 8)
		self:spawn(Torch, 9, 17)
		self:spawn(Torch, 28, 16)
		self:spawn(Torch, 27, 9)
		self:spawn(Torch, 23, 46)
		self:spawn(Torch, 14, 28)
		self:spawn(Torch, 3, 43)
		self:spawn(Torch, 25, 61)
		self:spawn(Torch, 48, 54)
		self:spawn(Torch, 52, 54)
		self:spawn(Torch, 59, 31)
		self:spawn(Torch, 45, 16)

		-- The (friendly) cavemen
		caveman1 = self:spawn(Caveman, 24, 4);
		caveman1.travel = 1;
		caveman2 = self:spawn(Caveman, 24, 3);
		caveman2.travel = 1;


		-- Hostile creatures

		self:spawn(EnemySpider, 58, 35)
		self:spawn(EnemySpider, 54, 34)
		self:spawn(EnemySpider, 41, 32)
		self:spawn(EnemySpider, 54, 46)
		self:spawn(EnemySpider, 43, 46)
		self:spawn(EnemySpider, 12, 59)
		self:spawn(EnemySpider, 28, 28)
		self:spawn(EnemySpider, 25, 19)
		self:spawn(EnemySpider, 24, 16)
		self:spawn(EnemySpider, 10, 30)
		self:spawn(EnemySpider, 22, 33)
		self:spawn(EnemySpider, 55, 22)
		self:spawn(EnemySpider, 54, 20)
		self:spawn(EnemySpider, 52, 22)

		self:spawn(EnemyPoisonSpider, 56, 36)
		self:spawn(EnemyPoisonSpider, 42, 34)
		self:spawn(EnemyPoisonSpider, 44, 33)
		self:spawn(EnemyPoisonSpider, 52, 45)
		self:spawn(EnemyPoisonSpider, 42, 47)
		self:spawn(EnemyPoisonSpider, 40, 46)
		self:spawn(EnemyPoisonSpider, 24, 61)
		self:spawn(EnemyPoisonSpider, 23, 63)
		self:spawn(EnemyPoisonSpider, 13, 57)
		self:spawn(EnemyPoisonSpider, 11, 58)
		self:spawn(EnemyPoisonSpider, 29, 27)
		self:spawn(EnemyPoisonSpider, 30, 28)
		self:spawn(EnemyPoisonSpider, 23, 18)
		self:spawn(EnemyPoisonSpider, 26, 17)
		self:spawn(EnemyPoisonSpider, 9, 31)
		self:spawn(EnemyPoisonSpider, 10, 32)
		self:spawn(EnemyPoisonSpider, 20, 32)
		self:spawn(EnemyPoisonSpider, 57, 20)


		self:spawn(EnemyCaveman, 47, 54);
		self:spawn(EnemyCaveman, 47, 56);
		self:spawn(EnemyCaveman, 54, 11);
		self:spawn(EnemyCaveman, 57, 11);
		self:spawn(EnemyCaveman, 31, 62);
		self:spawn(EnemyCaveman, 33, 62);
		self:spawn(EnemyCaveman, 10, 53);
		self:spawn(EnemyCaveman,  8, 53);
		
		obj = self:spawn(EnemyCaveman, 6, 16);
		obj.dir = DIR_LEFT
		
		self:spawn(EnemyCaveman, 5, 15);
		
		obj = self:spawn(EnemyCaveman, 4, 16);
		obj.dir = DIR_RIGHT


		-- Tunnel 1
		self:spawn(CaveTunnelTop, 32, 57)
		self:spawn(CaveRoof, 32, 57)
		self:spawn(CaveRoof, 32, 58)
		self:spawn(CaveRoof, 32, 59)
		self:spawn(CaveTunnelBottom, 32, 61)

		-- Tunnel 2
		self:spawn(CaveTunnelTop, 25, 11)
		self:spawn(CaveRoof, 25, 11)	
		self:spawn(CaveTunnelBottom, 25, 13)

		-- Tunnel 3
		self:spawn(CaveRoof, 24, 0)
		self:spawn(CaveRoof, 24, 1)
		self:spawn(CaveRoof, 24, 2)
		self:spawn(CaveRoof, 24, 3)
		self:spawn(CaveRoof, 24, 4)	
		self:spawn(CaveTunnelBottom, 24, 6)

		-- The bridge
		self:spawn(CaveBridge1, 50, 55)
		self:spawn(CaveBridge2, 50, 55)

		-- Falling asleep
		self:spawn(CaveFallingAsleep, 25, 10)

		-- Map transitions
		obj = self:spawn(Cave2_Naar_Cave1, 63, 64)
		obj.h = 4
	end;
}
