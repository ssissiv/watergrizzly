local constants = require "constants"
local modal_win = {}

function modal_win.new( gstate )
	local self = util.shallowcopy( modal_win )
	self.gstate = gstate
	return self
end

function modal_win:update()
	self.gstate:travelTo( "WIN" )

	while true do
		coroutine.yield()
	end
end

function modal_win:refreshOptions( options )
	table.insert( options, option_def.restart )
end

return modal_win
