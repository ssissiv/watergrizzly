require("modules/class")

local texprop = class()

local images = {}

function texprop:init( filename, size, layer )
	assert( layer )
	
	local image
	if images[filename] == nil then
		image = MOAIImage.new()
		image:load( "data/" ..filename, MOAIImage.PREMULTIPLY_ALPHA )
		images[filename] = image
	else
		image = images[filename]
	end
	
	local gfxQuad = MOAIGfxQuad2D.new ()
	gfxQuad:setTexture ( image )
	
	if size then
		gfxQuad:setRect ( -size, -size, size, size)
	else
		local w,h = image:getSize()
		gfxQuad:setRect ( -w/2, -h/2, w/2, h/2 )
	end
	
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

function texprop:setRot( a )
	self.prop:setRot( a )
end

function texprop:setColor( r, g, b, a )
	self.prop:setColor( r, g, b, a )
end

function texprop:destroy()
	if self.layer then
		self.layer:removeProp( self.prop )
	end
	self.prop = nil
	self.layer = nil
end


return texprop
