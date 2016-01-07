local constants = require "constants"
local modal_dead = {}

function modal_dead.new( gstate )
	local self = util.shallowcopy( modal_dead )
	self.gstate = gstate
	return self
end

function modal_dead:update()
	self.gstate:travelTo( "DEAD" )

	while true do
		coroutine.yield()
	end
end

function modal_dead:refreshOptions()
	self.gstate:addOption( option_def.game_over )
	self.gstate:addLine( "You find your final resting place in the boughs of the world tree..." )
end

return modal_dead
