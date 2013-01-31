require("modules/class")
local array = require("modules/array")
local util = require("modules/util")
local mathutil = require("modules/mathutil")
local cstiles = require("game/cstiles")

--------------------------------------------------

-- Finds a power source with at least 'power' for the sink at <gridx, gridy>
local function findPower( ship, power, gridx, gridy )

	local open_list = { { gridx, gridy, path = {} } }
	local close_list = {}
	
	while #open_list > 0 do
		local node = table.remove( open_list )
		table.insert( close_list, node )
		
		for i = 1, cstiles.TILE_COUNT do
			local gridx, gridy = cstiles.getTile( node[1], node[2], i )
			local pnode = array.findIf( close_list, function( n ) return gridx == n[1] and gridy == n[2] end )
			pnode = pnode or array.findIf( open_list, function( n ) return gridx == n[1] and gridy == n[2] end )
			
			if pnode == nil then
				local component = ship:getComponent( gridx, gridy )
				if component and (component.psource or -1) > power then
					-- Find power source.
					node.path[#node.path+1], node.path[#node.path+2] = gridx, gridy
					return node.path
					
				elseif component and component.ptrans then
					-- Conducting
					local path = util.tcopy( node.path )
					path[#path+1], path[#path+2] = gridx, gridy
					table.insert( open_list, { gridx, gridy, path = path} )
				end
			end
		end
	end
end

return
{
	findPower = findPower,
}
