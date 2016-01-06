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

function ttsys:draw( ttstr, mx, my )
	local BORDER = 10
	local font = love.graphics.getFont()
    local w, wraps = font:getWrap( ttstr, 200 )
	local ttwidth, ttheight = w + 2 * BORDER, #wraps * font:getHeight() + 2 * BORDER 
    if mx + ttwidth >= love.graphics.getWidth() then
    	mx = love.graphics.getWidth() - ttwidth
    elseif mx < 0 then
    	mx = 0
    end
    if my + ttheight >= love.graphics.getHeight() then
    	my = love.graphics.getHeight() - ttheight
    elseif my < 0 then
    	my = 0
    end

    -- BG
    love.graphics.setColor( 70, 50, 30, 255 )
    love.graphics.rectangle( "fill", mx, my, ttwidth, ttheight )
    love.graphics.setColor( 255, 255, 255, 255 )
    -- Tooltip text
    love.graphics.textf( ttstr, mx + BORDER, my + BORDER, 200, "left" )
end

ttsys.inst = ttsys.new()

return ttsys
