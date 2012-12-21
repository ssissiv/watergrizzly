require("modules/class")
local mathutil = require("modules/mathutil")

------------------------------------------------------

glink = class()

function glink:init( node0, node1 )
	assert( node0 and node1 and node0 ~= node1 )
	self.n0 = node0
	self.n1 = node1
end

function glink:getPosition()
	local x0, y0 = self.n0:getPosition()
	local x1, y1 = self.n1:getPosition()
	
	return x0, y0, x1, y1
end

return glink

