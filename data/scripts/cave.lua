-- cave.lua
-- Cave filling scripts


function prepare_cave1()
	m_add_object(56, 30, "Spring")

	-- Spider webs
	
	m_add_object(44,  3, "SpiderWeb")
	m_add_object(51, 17, "SpiderWeb")
	m_add_object(32, 49, "SpiderWeb")
	m_add_object( 2, 68, "SpiderWeb")
	m_add_object(21,  6, "SpiderWeb")
	
	m_add_object(62, 33, "SpiderWeb2")
	m_add_object(62, 61, "SpiderWeb2")
	m_add_object(10, 23, "SpiderWeb2")
	m_add_object(10,  3, "SpiderWeb2")

	-- Hostile creatures
	m_add_object( 9,  7, "EnemySpider")
	m_add_object(26, 64, "EnemyPoisonSpiderQueen")
	m_add_object(32, 66, "EnemySpider")
	m_add_object(53, 58, "EnemySpider")
	m_add_object(49, 59, "EnemySpider")
	m_add_object(30, 11, "EnemySpider")
	m_add_object(27, 15, "EnemySpider")
	m_add_object( 7, 29, "EnemySpider")
	m_add_object(10, 32, "EnemySpider")
	m_add_object(46, 21, "EnemySpider")
	m_add_object(61, 34, "EnemyPoisonSpiderQueen")
	m_add_object(60, 35, "EnemySpider")
	m_add_object(49, 42, "EnemySpider")
	m_add_object(42, 30, "EnemySpider")
	m_add_object(33, 31, "EnemySpider")
	m_add_object(45, 40, "EnemySpider")
	m_add_object(33, 30, "EnemySpider")
	m_add_object(25, 27, "EnemySpider")
	m_add_object(25, 18, "EnemySpider")
	m_add_object(23, 45, "EnemySpider")
	m_add_object( 5, 51, "EnemySpider")
	m_add_object( 9, 31, "EnemySpider")
	m_add_object( 7, 15, "EnemySpider")
	m_add_object(40, 70, "EnemySpider")

	m_add_object(43, 46, "EnemyPoisonSpider")
	m_add_object(25,  9, "EnemyPoisonSpiderQueen")
	m_add_object(21, 16, "EnemyPoisonSpider")
	m_add_object( 8, 35, "EnemyPoisonSpider")
	m_add_object( 9, 53, "EnemyPoisonSpider")
	m_add_object( 5, 55, "EnemyPoisonSpider")
	m_add_object(51, 61, "EnemyPoisonSpider")
	m_add_object( 7,  5, "EnemyPoisonSpider")
	m_add_object(32, 31, "EnemyPoisonSpider")
	m_add_object(22, 19, "EnemyPoisonSpider")
	m_add_object(27, 18, "EnemyPoisonSpider")
	m_add_object( 3, 15, "EnemyPoisonSpider")
	m_add_object( 4, 17, "EnemyPoisonSpider")
	m_add_object( 7, 68, "EnemyPoisonSpiderQueen")
	m_add_object(49, 68, "EnemyPoisonSpider")
	m_add_object(37, 68, "EnemyPoisonSpider")


	-- Torches
	m_add_object(51, 56, "Torch")
	m_add_object(58, 30, "Torch")
	m_add_object(53, 22, "Torch")
	m_add_object(22,  7, "Torch")
	m_add_object(29,  7, "Torch")
	m_add_object(20, 16, "Torch")
	m_add_object(29, 18, "Torch")
	m_add_object( 5, 56, "Torch")
	m_add_object(29, 63, "Torch")

	-- Flowing waterfall
	m_add_object(50, 3, "CaveWaterfallExit")

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
	m_add_object(16,32,"CavePile")

	-- Pick
	m_add_object(27,8,"CavePick")

	-- Map transitions
	obj = m_add_object(0,  7, "Cave1_Naar_Cave2")
	obj.h = 4
end

function prepare_cave2()
	m_add_object(44,  7, "Spring")
	m_add_object(6,  42, "Spring")
	
	-- Spider webs
	m_add_object(19,  7, "SpiderWeb")
	m_add_object( 1, 45, "SpiderWeb")
	m_add_object(30, 49, "SpiderWeb")
	m_add_object(43,  6, "SpiderWeb")

	m_add_object( 7,  7, "SpiderWeb2")
	m_add_object(32, 27, "SpiderWeb2")
	m_add_object(61, 18, "SpiderWeb2")
	
	-- Torches
	m_add_object( 6,  8, "Torch")
	m_add_object( 9, 17, "Torch")
	m_add_object(28, 16, "Torch")
	m_add_object(27,  9, "Torch")
	m_add_object(23, 46, "Torch")
	m_add_object(14, 28, "Torch")
	m_add_object( 3, 43, "Torch")
	m_add_object(25, 61, "Torch")
	m_add_object(48, 54, "Torch")
	m_add_object(52, 54, "Torch")
	m_add_object(59, 31, "Torch")
	m_add_object(45, 16, "Torch")

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

	m_add_object(58, 35, "EnemySpider")
	m_add_object(54, 34, "EnemySpider")
	m_add_object(41, 32, "EnemySpider")
	m_add_object(54, 46, "EnemySpider")
	m_add_object(43, 46, "EnemySpider")
	m_add_object(12, 59, "EnemySpider")
	m_add_object(28, 28, "EnemySpider")
	m_add_object(25, 19, "EnemySpider")
	m_add_object(24, 16, "EnemySpider")
	m_add_object(10, 30, "EnemySpider")
	m_add_object(22, 33, "EnemySpider")
	m_add_object(55, 22, "EnemySpider")
	m_add_object(54, 20, "EnemySpider")
	m_add_object(52, 22, "EnemySpider")

	m_add_object(56, 36, "EnemyPoisonSpider")
	m_add_object(42, 34, "EnemyPoisonSpider")
	m_add_object(44, 33, "EnemyPoisonSpider")
	m_add_object(52, 45, "EnemyPoisonSpider")
	m_add_object(42, 47, "EnemyPoisonSpider")
	m_add_object(40, 46, "EnemyPoisonSpider")
	m_add_object(24, 61, "EnemyPoisonSpider")
	m_add_object(23, 63, "EnemyPoisonSpider")
	m_add_object(13, 57, "EnemyPoisonSpider")
	m_add_object(11, 58, "EnemyPoisonSpider")
	m_add_object(29, 27, "EnemyPoisonSpider")
	m_add_object(30, 28, "EnemyPoisonSpider")
	m_add_object(23, 18, "EnemyPoisonSpider")
	m_add_object(26, 17, "EnemyPoisonSpider")
	m_add_object( 9, 31, "EnemyPoisonSpider")
	m_add_object(10, 32, "EnemyPoisonSpider")
	m_add_object(20, 32, "EnemyPoisonSpider")
	m_add_object(57, 20, "EnemyPoisonSpider")


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
	m_add_object(12, 12, "Spring")

	-- Torches
	m_add_object(30,  9, "Torch")
	m_add_object(40,  9, "Torch")
	m_add_object(30, 16, "Torch")
	m_add_object(40, 16, "Torch")

	m_add_object( 8, 34, "Torch")
	m_add_object(79, 34, "Torch")
	m_add_object(64, 27, "Torch")
	m_add_object(95, 27, "Torch")

	m_add_object(33, 18, "Torch")
	m_add_object(33, 23, "Torch")
	m_add_object(33, 28, "Torch")
	m_add_object(33, 33, "Torch")

	m_add_object(37, 18, "Torch")
	m_add_object(37, 23, "Torch")
	m_add_object(37, 28, "Torch")
	m_add_object(37, 33, "Torch")

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

	m_add_object(66, 25, "FenceL")
	m_add_object(67, 25, "Fence1")
	m_add_object(68, 25, "FenceG2")
	m_add_object(69, 25, "Fence2")
	m_add_object(70, 25, "FenceR")
	
	m_add_object(73, 25, "FenceL")
	m_add_object(74, 25, "Fence2")
	m_add_object(75, 25, "FenceG2")
	m_add_object(76, 25, "Fence1")
	m_add_object(77, 25, "FenceR")

	m_add_object(80, 25, "FenceL")
	m_add_object(81, 25, "Fence2")
	m_add_object(82, 25, "FenceG")
	m_add_object(83, 25, "Fence2")
	m_add_object(84, 25, "FenceR")

	m_add_object(87, 25, "FenceL")
	m_add_object(88, 25, "Fence1")
	m_add_object(89, 25, "FenceG2")
	m_add_object(90, 25, "Fence1")
	m_add_object(91, 25, "FenceR")
	
	m_add_object(35, 40, "CaveTunnelTop")

	static_boss = m_add_object(35, 11, "Boss")

	m_add_object(68, 34, "CaveNoticeStrong")
	obj = m_add_object(35, 12, "BossFightTrigger")
	obj.offset_y = -6
	boss_block = m_add_object(33, 18, "BossBlock")
end
