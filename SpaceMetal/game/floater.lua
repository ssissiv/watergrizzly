require( "modules/class" )
local mui = require("mui/mui")

-----------------------------------------------------

local chars = [[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ><{}[].,:;!@#$%^?()&*\/-+"|]]
local font, style

-----------------------------------------------------

local floater = class()

function floater:init( game, str, x, y, throbs, duration )
	if font == nil then
		font = MOAIFont.new ()
		font:loadFromTTF ( "data/arialbd.ttf", chars, 18, 128 )

		style = MOAITextStyle.new()
		style:setFont( font )
		style:setSize( 18 )
		style:setColor( 0.8, 0.9, 0.5, 1 )
	end
	
	throbs = throbs or 3
	
	self.game = game

	local w,h = 100, 60
	local prop = MOAITextBox.new()
	prop:setRect( -w/2, -h/2, w/2, h/2 )
	prop:setStyle( style )
	prop:setYFlip ( true )
	prop:setAlignment( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
	prop:setString( str )
	self.prop = prop
	local curve = MOAIAnimCurve.new ()
	curve:reserveKeys ( throbs * 2 )
	for i = 1,throbs * 2 do
		curve:setKey ( i, (duration or 1) * (i-1)/2, i % 2 )
	end

	self.prop:setAttrLink ( MOAIColor.ATTR_A_COL, curve, MOAIAnimCurve.ATTR_VALUE )
	self.prop:setLoc( x + 60, y )
	self.game.layer:insertProp( self.prop) 

	local timer = MOAITimer.new ()
	timer:setSpan ( 0, curve:getLength ())
	timer:setTime( math.random() * curve:getLength() )
	timer:setListener( MOAIAction.EVENT_STOP,
		function()
			self:destroy()
		end )

	curve:setAttrLink ( MOAIAnimCurve.ATTR_TIME, timer, MOAITimer.ATTR_TIME )

	timer:start()
end

function floater:destroy()
	self.game.layer:removeProp( self.prop )
end

return floater
