--
-- This object holds written text, to easy translation of the game.
--

import("Lang.lua")

CaveLang = Lang:subclass
{
	name = "BBRpgLang";


	--
	-- An array containing speaker names and single words or word combinations.
	--
	vars = {
		PLAYER     = "Frode",
		CAVEMAN    = "Caveman",
		CAVEMEN    = "Cavemen",
		THE_LORD   = "The Lord",

		HEALTH     = "Health",
		EXPERIENCE = "Experience",
		STRENGTH   = "Strength",
		DEXTERITY  = "Dexterity",
		AGILITY    = "Agility",
		ENDURANCE  = "Endurance",
	};


	--
	-- An array containing all the conversations present in the game
	--
	convs = {
		-- Game just starting

		INTRO = {
			{"{PLAYER}", "Arghh... My head hurts like hell. What happened?"},
			{"{PLAYER}", "Alright, if you've read the README.TXT then by now you'll know how I got stranded in this cave. Further more, you'll be informed about which keys to use to control me. Well now, let's get some exploration done."},
		},

		-- Pickaxe and pile of rubble

		PILE_WONT_BUDGE = {
			{"{PLAYER}", "It won't budge. I need some tool to get through this..."},
		},
		PICKUP_PICKAXE = {
			{"{PLAYER}", "This should come in handy for large stony obstacles!"},
		},
		USE_PICKAXE = {
			{"{PLAYER}", "Now let's see how this pickaxe works..."},
		},
		PICKAXE_WORKED = {
			{"{PLAYER}", "Pfew. That seems to have worked just fine. Pity my pickace was destroyed in the process."},
		},


		-- Player goes into prison

		YAWN_TIRED = {
			{"{PLAYER}",   "<Yawn> I'm tired... I really have to sit down for a while."},
		},
		QUIET_CORNER = {
			{"{PLAYER}",   "This seems like a quiet corner."},
		},
		REALLY_TIRED = {
			{"{PLAYER}",   "Djeezz... I'm really... tired..."},
		},
		DISCOVER_HUMAN = {
			{"{CAVEMAN}",  "What the hack? A human?! I must inform the king immediately."},
		},
		INFORM_KING = {
			{"{CAVEMAN}",  "Lord, do I have permission to speak?"},
			{"{THE_LORD}", "What is it, you lowly caveman slave of mine?"},
			{"{CAVEMAN}",  "Thank you for letting me speak Lord. I found a human asleep to the south of here."},
			{"{THE_LORD}", "Well, what have you done with him?"},
			{"{CAVEMAN}",  "Nothing, I thought I should tell you about it first..."},
			{"{THE_LORD}", "No, you shouldn't have told me first you imbecile! Bring him to me immediately!"},
			{"{CAVEMAN}",  "Yes Lord, of course."},
		},
		KICK_FIRST = {
			{"{CAVEMAN}",  "Wait! Let's make sure he doesn't wake up too soon."},
		},
		BRING_TO_KING = {
			{"{CAVEMAN}",  "Now let's bring him to the king."},
		},
		BROUGHT_HUMAN = {
			{"{CAVEMAN}",  "Lord, we've brought you the human."},
			{"{THE_LORD}", "I can see that you moron."},
			{"{CAVEMAN}",  "What do you want us to do with him?"},
			{"{THE_LORD}", "Hmmm... I'd like to eat him with breakfast. Until then, throw him into prison."},
			{"{CAVEMAN}",  "Yes Lord, of course."},
		},
		WHAT_THE = {
			{"{PLAYER}",   "What the..."},
		},
		WHAT_HAPPENED = {
			{"{PLAYER}",   "What happened? I'm in prison? I must have fallen asleep. Damn!"},
		},


		-- Player escapes from prison

		YEAH_RIGHT = {
			{"{PLAYER}",  "Yeah, right. Like they'd forget to lock a prison door."},
		},
		NOT_LOCKED = {
			{"{PLAYER}",  "Huh? It's not locked! These guys are really stupid!"},
		},
		WOW_ESCAPED = {
			{"{CAVEMAN}", "Wow, you escaped!"},
		},
		MUST_BE_STRONG = {
			{"{CAVEMAN}", "You must be very strong!"},
		},
		KING_IS_SLAVEDRIVER = {
			{"{PLAYER}",  "Well, I guess there is no point in denying that."},
			{"{CAVEMAN}", "You know, that big guy who commanded us to throw you into prison, he's a slavedriver to us!"},
			{"{PLAYER}",  "Ah."},
			{"{CAVEMAN}", "You might be strong enough to face him in a fight, it would free us from his evil might!"},
			{"{PLAYER}",  "Hmm. I'd like to ask him to go first, and just see what happens."},
			{"{CAVEMAN}", "Cool, we will be forever grateful!! The big bully is to the west, and then up north."},
		},


		-- Player reaches boss

		BOSS_AFTER_PRISON = {
			{"{PLAYER}",   "Hello Lord of the Cavemen."},
			{"{THE_LORD}", "WHAT? How did you escape from my prison!?"},
			{"{PLAYER}",   "I walked out really, though I did meet some resistance. But never mind that, I want to talk to you about something."},
			{"{THE_LORD}", "If you must. But I'm not the talkative type, so make it quick."},
			{"{PLAYER}",   "It has come to my knowledge that you are an evil slavedriver. Would you be so kind to step off the throne and let these Cavemen free?"},
			{"{THE_LORD}", "Over my fat body!"},
			{"{PLAYER}",   "I suppose that means no."},
			{"{THE_LORD}", "Indeed! Now feel my power, I've had enough and you'll pay for your ignorance!"},
		},
		BOSS_BEATEN_1 = {
			{"{THE_LORD}", "Blurk! Bwah! Blleeeh! You are too much for me."},
			{"{PLAYER}",   "Well, I'm glad that's over with."},
			{"{THE_LORD}", "Oh no, not so fast buddy. I might let you live for now, but I'll be back! Bigger, Badder and more Brutal than ever before! Muhahahaha!"},
		},
		BOSS_BEATEN_2 = {
			{"{PLAYER}",   "Well, I'm not falling for such stupid jokes. Let's see what the Cavemen have to say."},
		},
		BOSS_BEATEN_3 = {
			{"{CAVEMEN}",  "Hurray! Hurray! Hurray!"},
			{"{PLAYER}",   "Neat."},
		},

		-- Some tables with random texts.
		
		CDs = {
			{{"Frode", "Let's see if there's another CD of the Village People..."}},
		},
		Radio = {
			{{"Frode", "Cool music."}},
			{{"Frode", "I like the Beach Boys's music."}},
			{{"Frode", "Yeah! Great soundsystem!"}},
		},
		Refreshing = {
			{{"{PLAYER}", "Ah, refreshing."}},
			{{"{PLAYER}", "I could use some of that."}},
			{{"{PLAYER}", "That's much better."}},
		},
		Fire = {
			{{"{PLAYER}", "It's burning just fine."}},
			{{"{PLAYER}", "It's too big to carry along. Besides, I'd only use it for evil."}},
			{{"{PLAYER}", "Ouch! Fire hot."}},
			{{"{PLAYER}", "Is this a logfire I see before me?"}},
		},		
		Escape = {
			{{"{PLAYER}", "No way I can get out of this cave alive through this!"}},
			{{"{PLAYER}", "Escaping through this would kill me for sure."}},
		},
	};
}
