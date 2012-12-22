require( "modules/class" )
local texprop = require( "modules/texprop" )

-----------------------------------------------------

local indicator = class()

function indicator:init( game, filename, x, y, throbs, duration )
	assert( game.layer )
	
	throbs = throbs or 3
	
	self.game = game

	self.texprop = texprop( filename, nil, game.layer )

	local curve = MOAIAnimCurve.new ()
	curve:reserveKeys ( throbs * 2 )
	for i = 1,throbs * 2 do
		curve:setKey ( i, (duration or 1) * (i-1)/2, i % 2 )
	end

	self.texprop.prop:setAttrLink ( MOAIColor.ATTR_A_COL, curve, MOAIAnimCurve.ATTR_VALUE )
	self.texprop:setLoc( x, y )

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

function indicator:destroy()
	self.texprop:destroy()
end

return indicator
