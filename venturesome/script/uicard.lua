local constants = require "constants"
local util = require "util"
local uicard = {}

function uicard.new( card_def )
	local self = util.shallowcopy( uicard )
	self.def = card_def
	self.x, self.y = 0, 0
	return self
end

function uicard:moveTo( x, y )
	self.x, self.y = x, y
end

function uicard:getDef()
	return self.def
end

function uicard:isect( mx, my )
	return mx >= self.x and mx <= self.x + constants.CARD_WIDTH and my >= self.y and my <= self.y + constants.CARD_HEIGHT
end

function uicard:select( val )
	self.selected = val
end

function uicard:isSelected()
	return self.selected
end

function uicard:draw( dx, dy )
	local INSET = 4
	local x, y = self.x + (dx or 0), self.y + (dy or 0)
	love.graphics.setColor( 50, 50, 50, 255 )
	love.graphics.rectangle( "fill", x, y, constants.CARD_WIDTH, constants.CARD_HEIGHT )
	love.graphics.setColor( 50, 70, self.selected and 150 or 70, 255 )
	love.graphics.rectangle( "fill", x + INSET, y + INSET, constants.CARD_WIDTH - 2 * INSET, constants.CARD_HEIGHT - 2 * INSET )
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.print( self.def.name, x + 4, y + 4 )
	love.graphics.setColor( 235, 235, 235, 235 )
	love.graphics.printf( self.def.desc, x + 4, y + 64, constants.CARD_WIDTH - 4, "left" )
	love.graphics.printf( string.format( "Cost: %d", self.def.cost ), x, y + constants.CARD_HEIGHT - 24, constants.CARD_WIDTH - 2 * INSET, "center" )
end

return uicard



