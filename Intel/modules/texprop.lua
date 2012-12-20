require("modules/class")

local texprop = class()

function texprop:init( filename, size, layer )

	local image = MOAIImage.new()
	image:load( "data/" ..filename, MOAIImage.PREMULTIPLY_ALPHA )
	
    local gfxQuad = MOAIGfxQuad2D.new ()
    gfxQuad:setTexture ( image )
    gfxQuad:setRect ( -size, -size, size, size)

    local prop = MOAIProp2D.new ()
    prop:setDeck ( gfxQuad )
	prop:setBlendMode( MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE_MINUS_SRC_ALPHA )    
	
	self.prop = prop
	self.layer = layer
	
    layer:insertProp( prop )
	
	return prop
end

function texprop:setVisible( vis )
	self.prop:setVisible( vis )
end

function texprop:setLoc( x, y )
	self.prop:setLoc( x, y )
end

function texprop:getLoc()
	return self.prop:getLoc()
end

function texprop:seekLoc( x, y, t, ease )
	return self.prop:seekLoc( x, y, t, ease )
end

function texprop:setScl( sx, sy )
	self.prop:setScl( sx, sy )
end

function texprop:setColor( r, g, b, a )
	self.prop:setColor( r, g, b, a )
end

function texprop:destroy()
	self.layer:removeProp( self.prop )
	self.prop = nil
	self.layer = nil
end


return texprop
