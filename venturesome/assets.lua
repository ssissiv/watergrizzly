local assets =
{
	FONTS =
	{
		MAIN = love.graphics.newFont("Avenir-Book.ttf", 14),
		BOLD = love.graphics.newFont("Avenir-Black.ttf", 16),
		MINI = love.graphics.newFont("Avenir-Book.ttf", 12 )
	},

	IMGS =
	{
		MAP = love.graphics.newImage( "map.png" ),
		PRESTIGE = love.graphics.newImage( "resource_prestige.png" ),
		TIME = love.graphics.newImage( "resource_time.png" ),
	}
}


return assets