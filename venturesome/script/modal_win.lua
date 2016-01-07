local constants = require "constants"
local modal_win = {}

function modal_win.new( gstate )
	local self = util.shallowcopy( modal_win )
	self.gstate = gstate
	return self
end

function modal_win:update()
	while true do
		coroutine.yield()
	end
end

function modal_win:refreshOptions( options )
	self.gstate:addLine( "You have become the greatest hero the world has ever known. You save the land!" )
	self.gstate:addOption( option_def.restart )
end

return modal_win
