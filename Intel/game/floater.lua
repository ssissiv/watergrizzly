require( "modules/class" )
local mui = require("mui/mui")

-----------------------------------------------------

local floater = class()

function floater:init( game, str, x, y, throbs )
	throbs = throbs or 3
	
	self.game = game

	local w,h = 1000, 500
	local prop = MOAITextBox.new()
	prop:setRect( -w/2, -h/2, w/2, h/2 )
	for k,v in pairs(mui.getStyles()) do
		prop:setStyle( k, v)
	end
	prop:setStyle( mui:getStyles().default )
	prop:setYFlip ( true )
	prop:setAlignment( MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
	prop:setString( str )
	self.prop = prop
	local curve = MOAIAnimCurve.new ()
	curve:reserveKeys ( throbs * 2 )
	for i = 1,throbs * 2 do
		curve:setKey ( i, (i-1)/2, i % 2 )
	end
	print("FLOATER " ..str)
	self.prop:setAttrLink ( MOAIColor.ATTR_A_COL, curve, MOAIAnimCurve.ATTR_VALUE )
	self.prop:setLoc( x, y )

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
