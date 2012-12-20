require("modules/class")

local gintel = class()

function gintel:init( game )
	self.data = {}
	self.game = game
	self.omniscient = false
end

function gintel:setOmniscient( omni )
	self.omniscient = omni
end

function gintel:add( key, data )
	self.data[ key ] = data
	data.tick = self.game:getTick()
end

function gintel:rmv( key )
	self.data[ key ] = nil
end

function gintel:find( key )
	if self.omniscient then
		return key
	end
	
	return self.data[ key ]
end

function gintel:merge( intel )
	for k,their_info in pairs(intel.data) do
		local info = self:find( k )
		if info == nil then
			-- They have info, we don't
			self.data[k] = their_info
		elseif info == k then
			-- We have max info, don't care WHAT they have
		elseif their_info.tick > info.tick then
			-- Theirs is newer.
			self.data[k] = their_info
		end
	end
end

return gintel
