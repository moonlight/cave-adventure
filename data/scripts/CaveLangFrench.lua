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
lang.EXPERIENCE = "Exp�rience"
lang.STRENGTH   = "Force"
lang.DEXTERITY  = "Dext�rit�"
lang.AGILITY    = "Agilit�"
lang.ENDURANCE  = "Endurance"




--
-- An array containing all the conversations present in the game
--
conv = {}


-- Game just starting

conv.INTRO = {
	{lang.PLAYER, "Arghh... Ma t�te me fait un mal pas possible. Que s'est-il pass�?"},
	{lang.PLAYER, "Bien, si vous avez lu le README.TXT alors vous saurez comment je suis tomb� dans cette grotte. En outre, vous serez inform� des touches � utiliser pour me contr�ler. Bon maintenant, commen�ons l'exploration."},
}



-- Examining stuff

conv.NO_WAY_OUT = {{lang.PLAYER, "Il n'est pas question que je passe par ici pour m'enfuir!"}}
conv.NO_ESCAPE  = {{lang.PLAYER, "S'echapper en passant par l� me tuerait, c'est s�r."}}

conv.REFRESHING = {{lang.PLAYER, "Ah, �a fait du bien."}}
conv.COULD_USE_THAT = {{lang.PLAYER, "Je peux utiliser �a."}}
conv.MUCH_BETTER = {{lang.PLAYER, "Ca va mieux."}}

conv.FIRE_1 = {{lang.PLAYER, "Ca br�le bien."}}
conv.FIRE_2 = {{lang.PLAYER, "C'est trop gros pour �tre port�. En plus, I'd only use it for evil."}}
conv.FIRE_3 = {{lang.PLAYER, "Ouille! Ca br�le."}}
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
	{lang.PLAYER, "Pfou. Ca a march�. C'est dommage ma pioche s'est cass�e."},
}



-- Player goes into prison

conv.YAWN_TIRED = {
	{lang.PLAYER,   "<Yawn> Je suis fatigu�... J'ai vraiment besoin de m'assoir un moment."},
}
conv.QUIET_CORNER = {
	{lang.PLAYER,   "Cela me semble �tre un coin tranquille."},
}
conv.REALLY_TIRED = {
	{lang.PLAYER,   "RRzzzz... Je suis vraiment... fatigu�..."},
}
conv.DISCOVER_HUMAN = {
	{lang.CAVEMAN,  "Qu'est ce que c'est? Un humain?! Je dois en informer le roi imm�diatement."},
}
conv.INFORM_KING = {
	{lang.CAVEMAN,  "Seigneur, ai-je la permission de parler?"},
	{lang.THE_LORD, "Qu'y a t-il, humble serviteur?"},
	{lang.CAVEMAN,  "Je vous remercie de me laisser parler Seigneur. J'ai trouv� un humain assoupi. Il se trouve au sud d'ici."},
	{lang.THE_LORD, "Bien, qu'en as tu fait?"},
	{lang.CAVEMAN,  "Rien du tout, j'ai pens� qu'il �tait pr�f�rable de vous en parler d'abord..."},
	{lang.THE_LORD, "Non, Tu n'avais pas � m'en parler en premier imb�cile! Apporte le moi imm�diatement!"},
	{lang.CAVEMAN,  "Oui Seigneur, bien sur."},
}
conv.KICK_FIRST = {
	{lang.CAVEMAN,  "Attend! Frappons-le d'abord pour �tre sur qu'il soit inconscient!"},
}
conv.BRING_TO_KING = {
	{lang.CAVEMAN,  "Maintenant ramenons-le au roi."},
}
conv.BROUGHT_HUMAN = {
	{lang.CAVEMAN,  "Seigneur, nous vous avons rapport� l'humain."},
	{lang.THE_LORD, "Je le vois bien cr�tin!"},
	{lang.CAVEMAN,  "Que voulez vous que l'on en fasse?"},
	{lang.THE_LORD, "Hmmm... Je le mangerais bien au petit-d�jeuner. En attendant, jetez-le dans la prison."},
	{lang.CAVEMAN,  "Bien Seigneur, ce sera fait."},
}
conv.WHAT_THE = {
	{lang.PLAYER,   "Qu'est ce..."},
}
conv.WHAT_HAPPENED = {
	{lang.PLAYER,   "Qu'est-il arriv�? Je suis dans une prison? J'ai d� tomber la-dedans pendant mon sommeil. Mince!"},
}



-- Player escapes from prison

conv.YEAH_RIGHT = {
	{lang.PLAYER,  "Ouais, c'est bon. Ils avaient oubli� de fermer la porte de la prison."},
}
conv.NOT_LOCKED = {
	{lang.PLAYER,  "Hein? Ce n'est pas ferm�! Ces types sont vraiment stupides!"},
}
conv.WOW_ESCAPED = {
	{lang.CAVEMAN, "Woa, Tu t'es �chapp�!"},
}
conv.MUST_BE_STRONG = {
	{lang.CAVEMAN, "Tu dois �tre tr�s fort!"},
}
conv.KING_IS_SLAVEDRIVER = {
	{lang.PLAYER,  "Et bien, je ne vais pas le nier ..."},
	{lang.CAVEMAN, "Tu sais, c'est un gros bonhomme qui nous a dit de te jeter en prison, c'est notre n�grier!"},
	{lang.PLAYER,  "Ah."},
	{lang.CAVEMAN, "Tu dois �tre suffisamment fort pour lui faire face dans un combat, nous serions alors libre de cet �tre malfaisant!"},
	{lang.PLAYER,  "Hmm. Je voudrais lui parler d'abord, juste pour voir ce qui arriverait."},
	{lang.CAVEMAN, "Cool, nous te serions reconnaissant pour toujours!! Le terrible roi est � l'ouest, puis prend par le nord."},
}



-- Player reaches boss

conv.BOSS_AFTER_PRISON = {
	{lang.PLAYER,   "Salut Seigneur des hommes des cavernes."},
	{lang.THE_LORD, "QUOI? comment t'es-tu �chapp� de prison!?"},
	{lang.PLAYER,   "J'en suis sorti, pensez que j'ai rencontr� quelque r�sistance. Mais peu importe, je veux vous parler."},
	{lang.THE_LORD, "Si tu veux. Mais je ne suis pas tr�s bavard, alors fait vite."},
	{lang.PLAYER,   "J'ai appris que vous �tiez un maitre malfaisant envers vos sujets. Voudriez vous �tre cl�ment et laisser les hommes des cavernes libres?"},
	{lang.THE_LORD, "Il faudra passer sur mon �norme corps!"},
	{lang.PLAYER,   "Je suppose que cela veut dire non."},
	{lang.THE_LORD, "Bien s�r que cela veut dire non! Maintenant tu vas conna�tre mon pouvoir, j'en ai assez et tu vas payer pour ton ignorance!"},
}
conv.BOSS_BEATEN_1 = {
	{lang.THE_LORD, "Blurk! Bwah! Blleeeh! Tu es trop fort pour moi."},
	{lang.PLAYER,   "Merci, je suis content de savoir �a."},
	{lang.THE_LORD, "Et non, on ne sera pas si vite potes. Je te laisse vivre cette fois, mais je reviendrais! Plus gros, plus m�chant et plus brutal que jamais! Muhahahaha!"},
}
conv.BOSS_BEATEN_2 = {
	{lang.PLAYER,   "Bon, Je ne succombe pas � des blagues aussi stupides  . Ecoutez ce que les hommes des cavernes ont � vous dire."},
}
conv.BOSS_BEATEN_3 = {
	{lang.CAVEMEN,  "Hourra! Hourra! Hourra!"},
	{lang.PLAYER,   "Super."},
}

]]