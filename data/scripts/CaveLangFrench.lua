--
-- French translation of Cave Adventure
-- By Gregzenegair

--[[
--
-- An array containing speaker names and single words or word combinations.
--
lang = {}

lang.PLAYER     = "Frode"
lang.CAVEMAN    = "L'homme des cavernes"
lang.CAVEMEN    = "Les hommes des cavernes"
lang.THE_LORD   = "Le Seigneur"

lang.HEALTH     = "Vie"
lang.EXPERIENCE = "Expérience"
lang.STRENGTH   = "Force"
lang.DEXTERITY  = "Dextérité"
lang.AGILITY    = "Agilité"
lang.ENDURANCE  = "Endurance"




--
-- An array containing all the conversations present in the game
--
conv = {}


-- Game just starting

conv.INTRO = {
	{lang.PLAYER, "Arghh... Ma tête me fait un mal pas possible. Que s'est-il passé?"},
	{lang.PLAYER, "Bien, si vous avez lu le README.TXT alors vous saurez comment je suis tombé dans cette grotte. En outre, vous serez informé des touches à utiliser pour me contrôler. Bon maintenant, commençons l'exploration."},
}



-- Examining stuff

conv.NO_WAY_OUT = {{lang.PLAYER, "Il n'est pas question que je passe par ici pour m'enfuir!"}}
conv.NO_ESCAPE  = {{lang.PLAYER, "S'echapper en passant par là me tuerait, c'est sûr."}}

conv.REFRESHING = {{lang.PLAYER, "Ah, ça fait du bien."}}
conv.COULD_USE_THAT = {{lang.PLAYER, "Je peux utiliser ça."}}
conv.MUCH_BETTER = {{lang.PLAYER, "Ca va mieux."}}

conv.FIRE_1 = {{lang.PLAYER, "Ca brûle bien."}}
conv.FIRE_2 = {{lang.PLAYER, "C'est trop gros pour être porté. En plus, I'd only use it for evil."}}
conv.FIRE_3 = {{lang.PLAYER, "Ouille! Ca brûle."}}
conv.FIRE_4 = {{lang.PLAYER, "Est-ce un feu de bois que je vois devant moi?"}}



-- Pickaxe and pile of rubble

conv.PILE_WONT_BUDGE = {
	{lang.PLAYER, "Ca ne veut pas bouger. J'aurais besoin d'un outil pour pouvoir passer..."},
}
conv.PICKUP_PICKAXE = {
	{lang.PLAYER, "Cela pourrait me donner un coup de main pour bouger de grosses pierres!"},
}
conv.USE_PICKAXE = {
	{lang.PLAYER, "Maintenant, voyons ce que cette pioche a dans le ventre..."},
}
conv.PICKAXE_WORKED = {
	{lang.PLAYER, "Pfou. Ca a marché. C'est dommage ma pioche s'est cassée."},
}



-- Player goes into prison

conv.YAWN_TIRED = {
	{lang.PLAYER,   "<Yawn> Je suis fatigué... J'ai vraiment besoin de m'assoir un moment."},
}
conv.QUIET_CORNER = {
	{lang.PLAYER,   "Cela me semble être un coin tranquille."},
}
conv.REALLY_TIRED = {
	{lang.PLAYER,   "RRzzzz... Je suis vraiment... fatigué..."},
}
conv.DISCOVER_HUMAN = {
	{lang.CAVEMAN,  "Qu'est ce que c'est? Un humain?! Je dois en informer le roi immédiatement."},
}
conv.INFORM_KING = {
	{lang.CAVEMAN,  "Seigneur, ai-je la permission de parler?"},
	{lang.THE_LORD, "Qu'y a t-il, humble serviteur?"},
	{lang.CAVEMAN,  "Je vous remercie de me laisser parler Seigneur. J'ai trouvé un humain assoupi. Il se trouve au sud d'ici."},
	{lang.THE_LORD, "Bien, qu'en as tu fait?"},
	{lang.CAVEMAN,  "Rien du tout, j'ai pensé qu'il était préférable de vous en parler d'abord..."},
	{lang.THE_LORD, "Non, Tu n'avais pas à m'en parler en premier imbécile! Apporte le moi immédiatement!"},
	{lang.CAVEMAN,  "Oui Seigneur, bien sur."},
}
conv.KICK_FIRST = {
	{lang.CAVEMAN,  "Attend! Frappons-le d'abord pour être sur qu'il soit inconscient!"},
}
conv.BRING_TO_KING = {
	{lang.CAVEMAN,  "Maintenant ramenons-le au roi."},
}
conv.BROUGHT_HUMAN = {
	{lang.CAVEMAN,  "Seigneur, nous vous avons rapporté l'humain."},
	{lang.THE_LORD, "Je le vois bien crétin!"},
	{lang.CAVEMAN,  "Que voulez vous que l'on en fasse?"},
	{lang.THE_LORD, "Hmmm... Je le mangerais bien au petit-déjeuner. En attendant, jetez-le dans la prison."},
	{lang.CAVEMAN,  "Bien Seigneur, ce sera fait."},
}
conv.WHAT_THE = {
	{lang.PLAYER,   "Qu'est ce..."},
}
conv.WHAT_HAPPENED = {
	{lang.PLAYER,   "Qu'est-il arrivé? Je suis dans une prison? J'ai dû tomber la-dedans pendant mon sommeil. Mince!"},
}



-- Player escapes from prison

conv.YEAH_RIGHT = {
	{lang.PLAYER,  "Ouais, c'est bon. Ils avaient oublié de fermer la porte de la prison."},
}
conv.NOT_LOCKED = {
	{lang.PLAYER,  "Hein? Ce n'est pas fermé! Ces types sont vraiment stupides!"},
}
conv.WOW_ESCAPED = {
	{lang.CAVEMAN, "Woa, Tu t'es échappé!"},
}
conv.MUST_BE_STRONG = {
	{lang.CAVEMAN, "Tu dois être très fort!"},
}
conv.KING_IS_SLAVEDRIVER = {
	{lang.PLAYER,  "Et bien, je ne vais pas le nier ..."},
	{lang.CAVEMAN, "Tu sais, c'est un gros bonhomme qui nous a dit de te jeter en prison, c'est notre négrier!"},
	{lang.PLAYER,  "Ah."},
	{lang.CAVEMAN, "Tu dois être suffisamment fort pour lui faire face dans un combat, nous serions alors libre de cet être malfaisant!"},
	{lang.PLAYER,  "Hmm. Je voudrais lui parler d'abord, juste pour voir ce qui arriverait."},
	{lang.CAVEMAN, "Cool, nous te serions reconnaissant pour toujours!! Le terrible roi est à l'ouest, puis prend par le nord."},
}



-- Player reaches boss

conv.BOSS_AFTER_PRISON = {
	{lang.PLAYER,   "Salut Seigneur des hommes des cavernes."},
	{lang.THE_LORD, "QUOI? comment t'es-tu échappé de prison!?"},
	{lang.PLAYER,   "J'en suis sorti, pensez que j'ai rencontré quelque résistance. Mais peu importe, je veux vous parler."},
	{lang.THE_LORD, "Si tu veux. Mais je ne suis pas très bavard, alors fait vite."},
	{lang.PLAYER,   "J'ai appris que vous étiez un maitre malfaisant envers vos sujets. Voudriez vous être clément et laisser les hommes des cavernes libres?"},
	{lang.THE_LORD, "Il faudra passer sur mon énorme corps!"},
	{lang.PLAYER,   "Je suppose que cela veut dire non."},
	{lang.THE_LORD, "Bien sûr que cela veut dire non! Maintenant tu vas connaître mon pouvoir, j'en ai assez et tu vas payer pour ton ignorance!"},
}
conv.BOSS_BEATEN_1 = {
	{lang.THE_LORD, "Blurk! Bwah! Blleeeh! Tu es trop fort pour moi."},
	{lang.PLAYER,   "Merci, je suis content de savoir ça."},
	{lang.THE_LORD, "Et non, on ne sera pas si vite potes. Je te laisse vivre cette fois, mais je reviendrais! Plus gros, plus méchant et plus brutal que jamais! Muhahahaha!"},
}
conv.BOSS_BEATEN_2 = {
	{lang.PLAYER,   "Bon, Je ne succombe pas à des blagues aussi stupides  . Ecoutez ce que les hommes des cavernes ont à vous dire."},
}
conv.BOSS_BEATEN_3 = {
	{lang.CAVEMEN,  "Hourra! Hourra! Hourra!"},
	{lang.PLAYER,   "Super."},
}

]]