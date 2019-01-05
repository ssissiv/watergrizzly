class( "Assets" )

local NEBULA_DATA = love.image.newImageData( 512, 512 )
NEBULA_DATA:mapPixel( function (x, y, r, g, b, a)
	    -- template for defining your own pixel mapping function
	    -- perform computations giving the new values for r, g, b and a
	    -- ...
	    return x / 512, y / 512, 0.5, 1.0
	end )


Assets.FONTS =
{
}
strictify( Assets.FONTS )

Assets.IMGS =
{
	PARTICLE = love.graphics.newImage( "data/particle.png" ),
	NEBULA = love.graphics.newImage( NEBULA_DATA ),
}
strictify( Assets.IMGS )

Assets.SOUNDS =
{
}
strictify( Assets.SOUNDS )
