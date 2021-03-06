local constants = require "constants"
local option_def = require "option_def"

local modal_timeup = {}

function modal_timeup.new( gstate )
	local self = util.shallowcopy( modal_timeup )
	self.gstate = gstate
	return self
end

function modal_timeup:update()
	while true do
		coroutine.yield()
	end
end

function modal_timeup:refreshOptions()
	self.gstate:addLine( "Your eyes glaze over as the curse inflicts everlasting catatonia upon you." )
	self.gstate:addOption( option_def.game_over )
end

return modal_timeup
