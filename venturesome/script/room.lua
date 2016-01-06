local util = require "util"

---------------------------------

local room = {}

function room.new( t )
	local self = util.shallowcopy(room)
	self.bg = love.graphics.newImage( t.bg or "data/room_bg.png" )

	self.name = t.name or "Untitled"
	self.desc = t.desc or ""
	self.options = util.deepcopy( t.options )
	self.mapx, self.mapy = t.mapx, t.mapy
	return self
end

function room:draw()
	love.graphics.draw( self.bg, 0, 0, 0, love.graphics.getWidth() / self.bg:getWidth(), 300 / self.bg:getHeight() )
	if self.converted then
		love.graphics.setColor( 0, 255, 255, 255 )
	else
		love.graphics.setColor( 255, 255, 255, 255 )
	end
	love.graphics.text( "<!BOLD>" ..self.name .. "</>", 10, 10 )
	love.graphics.textf( self.desc, 10, 36, 400 )
	love.graphics.setColor( 255, 255, 255, 255 )
end

function room:ioptions()
	return ipairs( self.options )
end

function room:getOption( i )
	return self.options[ i ]
end



return room