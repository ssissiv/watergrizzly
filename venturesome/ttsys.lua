local ttsys = {}

function ttsys.new()
	local self = util.shallowcopy( ttsys )
	self.tooltips = {}
	return self
end

function ttsys:clear()
	table.clear( self.tooltips )
end

function ttsys:addTooltip( x0, y0, x1, y1, tt )
	table.insert( self.tooltips, { x0 = x0, y0 = y0, x1 = x1, y1 = y1, tt = tt })
end

function ttsys:findTooltip( x, y )
	for i, tt in ipairs( self.tooltips ) do
		if x >= tt.x0 and x <= tt.x1 and y >= tt.y0 and  y <= tt.y1 then
			if type(tt.tt) == "string" then
				return tt.tt
			elseif type(tt.tt) == "function" then
				return tt.tt()
			end
			break
		end
	end
end

ttsys.inst = ttsys.new()

return ttsys
