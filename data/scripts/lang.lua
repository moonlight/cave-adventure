-- lang.lua
-- Contains all the stuff that is being said in the game
-- By Bjørn Lindeijer


--
-- An array containing speaker names and single words or word combinations.
--
lang = {}

lang.PLAYER     = "Frode"
lang.CAVEMAN    = "Caveman"
lang.CAVEMEN    = "Cavemen"
lang.THE_LORD   = "The Lord"

lang.HEALTH     = "Health"
lang.EXPERIENCE = "Experience"
lang.STRENGTH   = "Strength"
lang.DEXTERITY  = "Dexterity"
lang.AGILITY    = "Agility"
lang.ENDURANCE  = "Endurance"




--
-- An array containing all the conversations present in the game
--
conv = {}


-- Game just starting

conv.INTRO = {
	{lang.PLAYER, "Arghh... My head hurts like hell. What happened?"},
	{lang.PLAYER, "Alright, if you've read the README.TXT then by now you'll know how I got stranded in this cave. Further more, you'll be informed about which keys to use to control me. Well now, let's get some exploration done."},
}



-- Examining stuff

conv.NO_WAY_OUT = {{lang.PLAYER, "No way I can get out of this cave alive through this!"}}
conv.NO_ESCAPE  = {{lang.PLAYER, "Escaping through this would kill me for sure."}}

conv.REFRESHING = {{lang.PLAYER, "Ah, refreshing."}}
conv.COULD_USE_THAT = {{lang.PLAYER, "I could use some of that."}}
conv.MUCH_BETTER = {{lang.PLAYER, "That's much better."}}

conv.FIRE_1 = {{lang.PLAYER, "It's burning just fine."}}
conv.FIRE_2 = {{lang.PLAYER, "It's too big to carry along. Besides, I'd only use it for evil."}}
conv.FIRE_3 = {{lang.PLAYER, "Ouch! Fire hot."}}
conv.FIRE_4 = {{lang.PLAYER, "Is this a logfire I see before me?"}}



-- Pickaxe and pile of rubble

conv.PILE_WONT_BUDGE = {
	{lang.PLAYER, "It won't budge. I need some tool to get through this..."},
}
conv.PICKUP_PICKAXE = {
	{lang.PLAYER, "This should come in handy for large stony obstacles!"},
}
conv.USE_PICKAXE = {
	{lang.PLAYER, "Now let's see how this pickaxe works..."},
}
conv.PICKAXE_WORKED = {
	{lang.PLAYER, "Pfew. That seems to have worked just fine. Pity my pickace was destroyed in the process."},
}



-- Player goes into prison

conv.YAWN_TIRED = {
	{lang.PLAYER,   "<Yawn> I'm tired... I really have to sit down for a while."},
}
conv.QUIET_CORNER = {
	{lang.PLAYER,   "This seems like a quiet corner."},
}
conv.REALLY_TIRED = {
	{lang.PLAYER,   "Djeezz... I'm really... tired..."},
}
conv.DISCOVER_HUMAN = {
	{lang.CAVEMAN,  "What the hack? A human?! I must inform the king immediately."},
}
conv.INFORM_KING = {
	{lang.CAVEMAN,  "Lord, do I have permission to speak?"},
	{lang.THE_LORD, "What is it, you lowly caveman slave of mine?"},
	{lang.CAVEMAN,  "Thank you for letting me speak Lord. I found a human asleep to the south of here."},
	{lang.THE_LORD, "Well, what have you done with him?"},
	{lang.CAVEMAN,  "Nothing, I thought I should tell you about it first..."},
	{lang.THE_LORD, "No, you shouldn't have told me first you imbecile! Bring him to me immediately!"},
	{lang.CAVEMAN,  "Yes Lord, of course."},
}
conv.KICK_FIRST = {
	{lang.CAVEMAN,  "Wait! Let's kick him unconscious first!"},
}
conv.BRING_TO_KING = {
	{lang.CAVEMAN,  "Now let's bring him to the king."},
}
conv.BROUGHT_HUMAN = {
	{lang.CAVEMAN,  "Lord, we've brought you the human."},
	{lang.THE_LORD, "I can see that you moron."},
	{lang.CAVEMAN,  "What do you want us to do with him?"},
	{lang.THE_LORD, "Hmmm... I'd like to eat him with breakfast. Until then, throw him into prison."},
	{lang.CAVEMAN,  "Yes Lord, of course."},
}
conv.WHAT_THE = {
	{lang.PLAYER,   "What the..."},
}
conv.WHAT_HAPPENED = {
	{lang.PLAYER,   "What happened? I'm in prison? I must have fallen asleep. Damn!"},
}



-- Player escapes from prison

conv.YEAH_RIGHT = {
	{lang.PLAYER,  "Yeah, right. Like they'd forget to lock a prison door."},
}
conv.NOT_LOCKED = {
	{lang.PLAYER,  "Huh? It's not locked! These guys are really stupid!"},
}
conv.WOW_ESCAPED = {
	{lang.CAVEMAN, "Wow, you escaped!"},
}
conv.MUST_BE_STRONG = {
	{lang.CAVEMAN, "You must be very strong!"},
}
conv.KING_IS_SLAVEDRIVER = {
	{lang.PLAYER,  "Well, I guess there is no point in denying that."},
	{lang.CAVEMAN, "You know, that big guy who commanded us to throw you into prison, he's a slavedriver to us!"},
	{lang.PLAYER,  "Ah."},
	{lang.CAVEMAN, "You might be strong enough to face him in a fight, it would free us from his evil might!"},
	{lang.PLAYER,  "Hmm. I'd like to ask him to go first, and just see what happens."},
	{lang.CAVEMAN, "Cool, we will be forever grateful!! The big bully is to the west, and then up north."},
}



-- Player reaches boss

conv.BOSS_AFTER_PRISON = {
	{lang.PLAYER,   "Hello Lord of the Cavemen."},
	{lang.THE_LORD, "WHAT? How did you escape from my prison!?"},
	{lang.PLAYER,   "I walked out really, though I did meet some resistance. But never mind that, I want to talk to you about something."},
	{lang.THE_LORD, "If you must. But I'm not the talkative type, so make it quick."},
	{lang.PLAYER,   "It has come to my knowledge that you are an evil slavedriver. Would you be so kind to step off the throne and let these Cavemen free?"},
	{lang.THE_LORD, "Over my fat body!"},
	{lang.PLAYER,   "I suppose that means no."},
	{lang.THE_LORD, "Indeed! Now feel my power, I've had enough and you'll pay for your ignorance!"},
}
conv.BOSS_BEATEN_1 = {
	{lang.THE_LORD, "Blurk! Bwah! Blleeeh! You are too much for me."},
	{lang.PLAYER,   "Well, I'm glad that's over with."},
	{lang.THE_LORD, "Oh no, not so fast buddy. I might let you live for now, but I'll be back! Bigger, Badder and more Brutal than ever before! Muhahahaha!"},
}
conv.BOSS_BEATEN_2 = {
	{lang.PLAYER,   "Well, I'm not falling for such stupid jokes. Let's see what the Cavemen have to say."},
}
conv.BOSS_BEATEN_3 = {
	{lang.CAVEMEN,  "Hurray! Hurray! Hurray!"},
	{lang.PLAYER,   "Neat."},
}

