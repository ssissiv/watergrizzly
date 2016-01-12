local assets =
{
	FONTS =
	{
		MAIN = love.graphics.newFont("data/Avenir-Book.ttf", 14),
		BOLD = love.graphics.newFont("data/Avenir-Black.ttf", 16),
		MINI = love.graphics.newFont("data/Avenir-Book.ttf", 12 )
	},

	IMGS =
	{
		MAP = love.graphics.newImage( "data/map.png" ),
		PRESTIGE = love.graphics.newImage( "data/resource_prestige.png" ),
		TIME = love.graphics.newImage( "data/resource_time.png" ),
		LIFE_FULL = love.graphics.newImage( "data/heart_full.png" ),
		LIFE_EMPTY = love.graphics.newImage( "data/heart_empty.png" ),
	}
}


return assets