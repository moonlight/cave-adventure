-- cave.lua
-- Cave filling scripts


function prepare_cave1()
	Actor:spawn(Spring, 56, 30)

	local radio = Actor:spawn(Radio, 54, 3)
	radio.offset_y = radio.offset_y + 5

	-- Spider webs
	
	Actor:spawn(SpiderWeb, 44, 3)
	Actor:spawn(SpiderWeb, 51, 17)
	Actor:spawn(SpiderWeb, 32, 49)
	Actor:spawn(SpiderWeb, 2, 68)
	Actor:spawn(SpiderWeb, 21, 6)
	
	Actor:spawn(SpiderWeb2, 62, 33)
	Actor:spawn(SpiderWeb2, 62, 61)
	Actor:spawn(SpiderWeb2, 10, 23)
	Actor:spawn(SpiderWeb2, 10, 3)

	-- Hostile creatures
	Actor:spawn(EnemySpider, 9, 7)
	Actor:spawn(EnemyPoisonSpiderQueen, 26, 64)
	Actor:spawn(EnemySpider, 32, 66)
	Actor:spawn(EnemySpider, 53, 58)
	Actor:spawn(EnemySpider, 49, 59)
	Actor:spawn(EnemySpider, 30, 11)
	Actor:spawn(EnemySpider, 27, 15)
	Actor:spawn(EnemySpider, 7, 29)
	Actor:spawn(EnemySpider, 10, 32)
	Actor:spawn(EnemySpider, 46, 21)
	Actor:spawn(EnemyPoisonSpiderQueen, 61, 34)
	Actor:spawn(EnemySpider, 60, 35)
	Actor:spawn(EnemySpider, 49, 42)
	Actor:spawn(EnemySpider, 42, 30)
	Actor:spawn(EnemySpider, 33, 31)
	Actor:spawn(EnemySpider, 45, 40)
	Actor:spawn(EnemySpider, 33, 30)
	Actor:spawn(EnemySpider, 25, 27)
	Actor:spawn(EnemySpider, 25, 18)
	Actor:spawn(EnemySpider, 23, 45)
	Actor:spawn(EnemySpider, 5, 51)
	Actor:spawn(EnemySpider, 9, 31)
	Actor:spawn(EnemySpider, 7, 15)
	Actor:spawn(EnemySpider, 40, 70)

	Actor:spawn(EnemyPoisonSpider, 43, 46)
	Actor:spawn(EnemyPoisonSpiderQueen, 25, 9)
	Actor:spawn(EnemyPoisonSpider, 21, 16)
	Actor:spawn(EnemyPoisonSpider, 8, 35)
	Actor:spawn(EnemyPoisonSpider, 9, 53)
	Actor:spawn(EnemyPoisonSpider, 5, 55)
	Actor:spawn(EnemyPoisonSpider, 51, 61)
	Actor:spawn(EnemyPoisonSpider, 7, 5)
	Actor:spawn(EnemyPoisonSpider, 32, 31)
	Actor:spawn(EnemyPoisonSpider, 22, 19)
	Actor:spawn(EnemyPoisonSpider, 27, 18)
	Actor:spawn(EnemyPoisonSpider, 3, 15)
	Actor:spawn(EnemyPoisonSpider, 4, 17)
	Actor:spawn(EnemyPoisonSpiderQueen, 7, 68)
	Actor:spawn(EnemyPoisonSpider, 49, 68)
	Actor:spawn(EnemyPoisonSpider, 37, 68)


	-- Torches
	-- EXPERIMENTAL CREATION OF THE TORCHES
	Actor:spawn(Torch, 51, 56)
	Actor:spawn(Torch, 58, 30)
	Actor:spawn(Torch, 53, 22)
	Actor:spawn(Torch, 22, 7)
	Actor:spawn(Torch, 29, 7)
	Actor:spawn(Torch, 20, 16)
	Actor:spawn(Torch, 29, 18)
	Actor:spawn(Torch, 5,  56)
	Actor:spawn(Torch, 29, 63)

	-- Flowing waterfall
	Actor:spawn(CaveWaterfallExit, 50, 3)

	-- Add something generating music
	-- obj = m_add_object(54, 3, "Radio")
	-- obj.offset_y = obj.offset_y + 6

	-- The tunnel
	m_add_object(8, 67, "CaveTunnelBottom")
	m_add_object(8, 59, "CaveTunnelTop")
	for i = 59, 65 do
		obj = m_add_object(8, i, "CaveRoof")
	end
	obj.offset_y = obj.offset_y - 1

	-- The bridge
	m_add_object(45,68,"CaveBridge1")
	m_add_object(45,68,"CaveBridge2")

	-- Pile of rubble
	Actor:spawn(CavePile, 16, 32)

	-- Pick
	Actor:spawn(CavePick, 27, 8)

	-- Map transitions
	obj = m_add_object(0,  7, "Cave1_Naar_Cave2")
	obj.h = 4
end

function prepare_cave2()
	Actor:spawn(Spring, 44, 7)
	Actor:spawn(Spring, 6, 42)
	
	-- Spider webs
	Actor:spawn(SpiderWeb, 19, 7)
	Actor:spawn(SpiderWeb, 1, 45)
	Actor:spawn(SpiderWeb, 30, 49)
	Actor:spawn(SpiderWeb, 43, 6)

	Actor:spawn(SpiderWeb2, 7, 7)
	Actor:spawn(SpiderWeb2, 32, 27)
	Actor:spawn(SpiderWeb2, 61, 18)
	
	-- Torches
	Actor:spawn(Torch, 6, 8)
	Actor:spawn(Torch, 9, 17)
	Actor:spawn(Torch, 28, 16)
	Actor:spawn(Torch, 27, 9)
	Actor:spawn(Torch, 23, 46)
	Actor:spawn(Torch, 14, 28)
	Actor:spawn(Torch, 3, 43)
	Actor:spawn(Torch, 25, 61)
	Actor:spawn(Torch, 48, 54)
	Actor:spawn(Torch, 52, 54)
	Actor:spawn(Torch, 59, 31)
	Actor:spawn(Torch, 45, 16)

	-- The (friendly) cavemen
	if (not caveman1) then
		caveman1 = m_add_object(24,  4, "Caveman");
		caveman1.travel = 1;
	end
	if (not caveman2) then
		caveman2 = m_add_object(24,  3, "Caveman");
		caveman2.travel = 1;
	end


	-- Hostile creatures

	Actor:spawn(EnemySpider, 58, 35)
	Actor:spawn(EnemySpider, 54, 34)
	Actor:spawn(EnemySpider, 41, 32)
	Actor:spawn(EnemySpider, 54, 46)
	Actor:spawn(EnemySpider, 43, 46)
	Actor:spawn(EnemySpider, 12, 59)
	Actor:spawn(EnemySpider, 28, 28)
	Actor:spawn(EnemySpider, 25, 19)
	Actor:spawn(EnemySpider, 24, 16)
	Actor:spawn(EnemySpider, 10, 30)
	Actor:spawn(EnemySpider, 22, 33)
	Actor:spawn(EnemySpider, 55, 22)
	Actor:spawn(EnemySpider, 54, 20)
	Actor:spawn(EnemySpider, 52, 22)

	Actor:spawn(EnemyPoisonSpider, 56, 36)
	Actor:spawn(EnemyPoisonSpider, 42, 34)
	Actor:spawn(EnemyPoisonSpider, 44, 33)
	Actor:spawn(EnemyPoisonSpider, 52, 45)
	Actor:spawn(EnemyPoisonSpider, 42, 47)
	Actor:spawn(EnemyPoisonSpider, 40, 46)
	Actor:spawn(EnemyPoisonSpider, 24, 61)
	Actor:spawn(EnemyPoisonSpider, 23, 63)
	Actor:spawn(EnemyPoisonSpider, 13, 57)
	Actor:spawn(EnemyPoisonSpider, 11, 58)
	Actor:spawn(EnemyPoisonSpider, 29, 27)
	Actor:spawn(EnemyPoisonSpider, 30, 28)
	Actor:spawn(EnemyPoisonSpider, 23, 18)
	Actor:spawn(EnemyPoisonSpider, 26, 17)
	Actor:spawn(EnemyPoisonSpider, 9, 31)
	Actor:spawn(EnemyPoisonSpider, 10, 32)
	Actor:spawn(EnemyPoisonSpider, 20, 32)
	Actor:spawn(EnemyPoisonSpider, 57, 20)


	m_add_object(47, 54, "EnemyCaveman");
	m_add_object(47, 56, "EnemyCaveman");
	m_add_object(54, 11, "EnemyCaveman");
	m_add_object(57, 11, "EnemyCaveman");
	m_add_object(31, 62, "EnemyCaveman");
	m_add_object(33, 62, "EnemyCaveman");
	m_add_object(10, 53, "EnemyCaveman");
	m_add_object( 8, 53, "EnemyCaveman");
	
	obj = m_add_object( 6, 16, "EnemyCaveman");
	obj.dir = DIR_LEFT
	
	m_add_object( 5, 15, "EnemyCaveman");
	
	obj = m_add_object( 4, 16, "EnemyCaveman");
	obj.dir = DIR_RIGHT


	-- Tunnel 1
	m_add_object(32, 57, "CaveTunnelTop")
	m_add_object(32, 57, "CaveRoof")
	m_add_object(32, 58, "CaveRoof")
	m_add_object(32, 59, "CaveRoof")
	m_add_object(32, 61, "CaveTunnelBottom")

	-- Tunnel 2
	m_add_object(25, 11, "CaveTunnelTop")
	m_add_object(25, 11, "CaveRoof")	
	m_add_object(25, 13, "CaveTunnelBottom")

	-- Tunnel 3
	m_add_object(24,  0, "CaveRoof")
	m_add_object(24,  1, "CaveRoof")
	m_add_object(24,  2, "CaveRoof")
	m_add_object(24,  3, "CaveRoof")
	m_add_object(24,  4, "CaveRoof")	
	m_add_object(24,  6, "CaveTunnelBottom")

	-- The bridge
	m_add_object(50, 55, "CaveBridge1")
	m_add_object(50, 55, "CaveBridge2")

	-- Falling asleep
	m_add_object(25,  10, "CaveFallingAsleep")

	-- Map transitions
	obj = m_add_object(63,  64, "Cave2_Naar_Cave1")
	obj.h = 4
end

function prepare_cave3()
	Actor:spawn(Spring, 12, 12)

	-- Torches
	Actor:spawn(Torch, 30, 9)
	Actor:spawn(Torch, 40, 9)
	Actor:spawn(Torch, 30, 16)
	Actor:spawn(Torch, 40, 16)

	Actor:spawn(Torch, 8, 34)
	Actor:spawn(Torch, 79, 34)
	Actor:spawn(Torch, 64, 27)
	Actor:spawn(Torch, 95, 27)

	Actor:spawn(Torch, 33, 18)
	Actor:spawn(Torch, 33, 23)
	Actor:spawn(Torch, 33, 28)
	Actor:spawn(Torch, 33, 33)

	Actor:spawn(Torch, 37, 18)
	Actor:spawn(Torch, 37, 23)
	Actor:spawn(Torch, 37, 28)
	Actor:spawn(Torch, 37, 33)

	-- Cavemen

	obj = m_add_object(33, 20, "Caveman")
	obj.dir = DIR_RIGHT
	cavem1 = obj
	obj = m_add_object(33, 25, "Caveman")
	obj.dir = DIR_RIGHT
	cavem2 = obj
	obj = m_add_object(33, 30, "Caveman")
	obj.dir = DIR_RIGHT
	cavem3 = obj
	obj = m_add_object(37, 20, "Caveman")
	obj.dir = DIR_LEFT
	cavem4 = obj
	obj = m_add_object(37, 25, "Caveman")
	obj.dir = DIR_LEFT
	cavem5 = obj
	obj = m_add_object(37, 30, "Caveman")
	obj.dir = DIR_LEFT
	cavem6 = obj

	caveman_guard1 = m_add_object(80, 27, "EnemyCaveman")
	caveman_guard1.dir = DIR_RIGHT
	caveman_guard1:setState(AI_WAITING)
	caveman_guard2 = m_add_object(84, 27, "EnemyCaveman")
	caveman_guard2.dir = DIR_LEFT
	caveman_guard2:setState(AI_WAITING)
	caveman_guard3 = m_add_object(79, 27, "EnemyCaveman")
	caveman_guard3.dir = DIR_DOWN
	caveman_guard3:setState(AI_WAITING)
	caveman_guard4 = m_add_object(85, 27, "EnemyCaveman")
	caveman_guard4.dir = DIR_DOWN
	caveman_guard4:setState(AI_WAITING)

	-- Fences in prison

	Actor:spawn(FenceL,  66, 25)
	Actor:spawn(Fence1,  67, 25)
	Actor:spawn(FenceG2, 68, 25)
	Actor:spawn(Fence2,  69, 25)
	Actor:spawn(FenceR,  70, 25)
	
	Actor:spawn(FenceL,  73, 25)
	Actor:spawn(Fence2,  74, 25)
	Actor:spawn(FenceG2, 75, 25)
	Actor:spawn(Fence1,  76, 25)
	Actor:spawn(FenceR,  77, 25)

	Actor:spawn(FenceL,  80, 25)
	Actor:spawn(Fence2,  81, 25)
	Actor:spawn(FenceG,  82, 25)
	Actor:spawn(Fence2,  83, 25)
	Actor:spawn(FenceR,  84, 25)

	Actor:spawn(FenceL,  87, 25)
	Actor:spawn(Fence1,  88, 25)
	Actor:spawn(FenceG2, 89, 25)
	Actor:spawn(Fence1,  90, 25)
	Actor:spawn(FenceR,  91, 25)
	
	m_add_object(35, 40, "CaveTunnelTop")

	static_boss = m_add_object(35, 11, "Boss")

	m_add_object(68, 34, "CaveNoticeStrong")
	obj = m_add_object(35, 12, "BossFightTrigger")
	obj.offset_y = -6
	boss_block = m_add_object(33, 18, "BossBlock")
end
