--
-- The first cave map, with the cave entrance.
--

import("Map.lua")

Cave1 = Map:subclass
{
	name = "Cave1";

	init = function(self)
		Map.init(self, "data/maps/cave1.map")

		self:spawn(Spring, 56, 30 + 1)

		local radio = self:spawn(Radio, 54, 3 + 1)
		radio.offset_y = radio.offset_y + 15

		-- Spider webs
		
		self:spawn(SpiderWeb, 44, 3 + 1)
		self:spawn(SpiderWeb, 51, 17 + 1)
		self:spawn(SpiderWeb, 32, 49 + 1)
		self:spawn(SpiderWeb, 2, 68 + 1)
		self:spawn(SpiderWeb, 21, 6 + 1)
		
		self:spawn(SpiderWeb2, 62, 33 + 1)
		self:spawn(SpiderWeb2, 62, 61 + 1)
		self:spawn(SpiderWeb2, 10, 23 + 1)
		self:spawn(SpiderWeb2, 10, 3 + 1)

		-- Hostile creatures
		self:spawn(EnemySpider, 9, 7 + 1)
		self:spawn(EnemyPoisonSpiderQueen, 26, 64 + 1)
		self:spawn(EnemySpider, 32, 66 + 1)
		self:spawn(EnemySpider, 53, 58 + 1)
		self:spawn(EnemySpider, 49, 59 + 1)
		self:spawn(EnemySpider, 30, 11 + 1)
		self:spawn(EnemySpider, 27, 15 + 1)
		self:spawn(EnemySpider, 7, 29 + 1)
		self:spawn(EnemySpider, 10, 32 + 1)
		self:spawn(EnemySpider, 46, 21 + 1)
		self:spawn(EnemyPoisonSpiderQueen, 61, 34 + 1)
		self:spawn(EnemySpider, 60, 35 + 1)
		self:spawn(EnemySpider, 49, 42 + 1)
		self:spawn(EnemySpider, 42, 30 + 1)
		self:spawn(EnemySpider, 33, 31 + 1)
		self:spawn(EnemySpider, 45, 40 + 1)
		self:spawn(EnemySpider, 33, 30 + 1)
		self:spawn(EnemySpider, 25, 27 + 1)
		self:spawn(EnemySpider, 25, 18 + 1)
		self:spawn(EnemySpider, 23, 45 + 1)
		self:spawn(EnemySpider, 5, 51 + 1)
		self:spawn(EnemySpider, 9, 31 + 1)
		self:spawn(EnemySpider, 7, 15 + 1)
		self:spawn(EnemySpider, 40, 70 + 1)

		self:spawn(EnemyPoisonSpider, 43, 46 + 1)
		self:spawn(EnemyPoisonSpiderQueen, 25, 9 + 1)
		self:spawn(EnemyPoisonSpider, 21, 16 + 1)
		self:spawn(EnemyPoisonSpider, 8, 35 + 1)
		self:spawn(EnemyPoisonSpider, 9, 53 + 1)
		self:spawn(EnemyPoisonSpider, 5, 55 + 1)
		self:spawn(EnemyPoisonSpider, 51, 61 + 1)
		self:spawn(EnemyPoisonSpider, 7, 5 + 1)
		self:spawn(EnemyPoisonSpider, 32, 31 + 1)
		self:spawn(EnemyPoisonSpider, 22, 19 + 1)
		self:spawn(EnemyPoisonSpider, 27, 18 + 1)
		self:spawn(EnemyPoisonSpider, 3, 15 + 1)
		self:spawn(EnemyPoisonSpider, 4, 17 + 1)
		self:spawn(EnemyPoisonSpiderQueen, 7, 68 + 1)
		self:spawn(EnemyPoisonSpider, 49, 68 + 1)
		self:spawn(EnemyPoisonSpider, 37, 68 + 1)


		-- Torches
		self:spawn(Torch, 51, 56 + 1)
		self:spawn(Torch, 58, 30 + 1)
		self:spawn(Torch, 53, 22 + 1)
		self:spawn(Torch, 22, 7 + 1)
		self:spawn(Torch, 29, 7 + 1)
		self:spawn(Torch, 20, 16 + 1)
		self:spawn(Torch, 29, 18 + 1)
		self:spawn(Torch, 5,  56 + 1)
		self:spawn(Torch, 29, 63 + 1)

		-- Flowing waterfall
		self:spawn(CaveWaterfallExit, 50.5, 3 + 1)

		-- The tunnel
		self:spawn(CaveTunnelBottom, 8, 67 + 1)
		self:spawn(CaveTunnelTop, 8, 59 + 1)
		for i = 59, 65 do
			obj = self:spawn(CaveRoof, 8, i + 1)
		end
		obj.offset_y = obj.offset_y - 1

		-- The bridge
		self:spawn(CaveBridge1, 45, 68 + 1)
		self:spawn(CaveBridge2, 45, 68 + 1)

		-- Pile of rubble
		self:spawn(CavePile, 16, 32 + 1)

		-- Pick
		self:spawn(CavePick, 27, 8 + 1)

		-- Map transitions
		obj = self:spawn(Cave1_Naar_Cave2, 0, 7 + 1)
		obj.h = 4
	end;
}
