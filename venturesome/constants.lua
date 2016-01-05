return
{
	PARTICLE_LIFE = 60,

	PRESTIGE_MAX = 10, 
	
	COLOURS =
	{
		WHITE = { 255, 255, 255, 255 },
		RED = { 255, 0, 0, 255 },
		BLUE = { 0, 0, 255, 255 },
		GREEN = { 0, 255, 0, 255 },
		GRAY = { 128, 128, 128, 255 },
	},
	
	GSTATE = MakeEnum{ "TRAVEL", "DEAD", "TIMEUP", "CAMP" },

	RESOURCE = MakeEnum{ "ACTION", "TIME", "PRESTIGE", "EXP", "BUYS" },

	CARD = MakeEnum{ "EXP", "PRESTIGE", "ACTION", "CURSE" },
	CARD_WIDTH = 140,
	CARD_HEIGHT = 200,
}