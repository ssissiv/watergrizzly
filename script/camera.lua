class( "Camera" )

function Camera:init()
	self.x, self.y = 0, 0
	self.targetx, self.targety = 0, 0
	self.zoom = 1.0
end

function Camera:GetPosition()
	return self.x, self.y
end

function Camera:UpdateCamera( dt )
	self.x = (self.x + self.targetx) * 0.5
	self.y = (self.y + self.targety) * 0.5
end

function Camera:SetCameraBounds( x1, y1, x2, y2 )
	self.bounds = { x1, y1, x2, y2 }
end

function Camera:ZoomTo( zoom )
	assert( zoom > 0 )
	self.zoom = zoom
	self.x, self.y = self:ClampToBounds( self.x, self.y )
end

function Camera:ZoomToLevel( level, x, y )
	local x0, y0
	if x and y then
		x0, y0 = self:ScreenToWorld( x, y )
	end

	-- translate level level to zoom.  Level 0 means DEFAULT_ZOOM, >0 means greater zoom, <0 means less zoom.
	if level == 0 then
		self:ZoomTo( DEFAULT_ZOOM )
	elseif level > 0 then
		self:ZoomTo( DEFAULT_ZOOM * (level/5 + 1) )
	elseif level < 0 then
		self:ZoomTo( DEFAULT_ZOOM / math.abs(level/5 - 1) )
	end

	if x and y then
		-- zoom to this point
		local x1, y1 = self:ScreenToWorld( x, y )
		self:Offset( x0 - x1, y0 - y1 )
	end
end

function Camera:MoveTo( x, y )
	self.x, self.y = self:ClampToBounds( x, y )
	self.targetx, self.targety = self.x, self.y
end

function Camera:Offset( dx, dy )
	self.x = self.x + (dx or 0)
	self.y = self.y + (dy or 0)
	self.x, self.y = self:ClampToBounds( self.x, self.y )
	self.targetx, self.targety = self.x, self.y
end

function Camera:PanTo( x, y )
	self.targetx, self.targety = self:ClampToBounds( x, y )
end

function Camera:Pan( dx, dy )
	self.targetx = self.targetx + (dx or 0)
	self.targety = self.targety + (dy or 0)
	self.targetx, self.targety = self:ClampToBounds( self.targetx, self.targety )
end

function Camera:ClampToBounds( x, y )
	if self.bounds == nil then
		return x, y
	end

	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	local x1 = 0 * self.zoom + x
	local y1 = 0 * self.zoom + y
	local x2 = sw * self.zoom + x
	local y2 = sh * self.zoom + y

	local xmin, xmax = self.bounds[1] - (sw * 0.1), self.bounds[3] + (sw * 0.1)
	local ymin, ymax = self.bounds[2] - (sh * 0.1), self.bounds[4] + (sh * 0.1)
	if x1 < xmin and x2 < xmax then
		x = x + (xmin - x1)
	elseif x2 > xmax and x1 > xmin then
		x = x + (xmax - x2)
	end
	if y1 < ymin and y2 < ymax then
		y = y + (ymin - y1)
	elseif y2 > ymax and y1 > ymin then
		y = y + (ymax - y2)
	end
	return x, y
end

function Camera:ScreenToWorld( mx, my )
	local x = mx * self.zoom + self.x
	local y = my * self.zoom + self.y
	return x, y
end

function Camera:WorldToScreen( x, y )
	local mx = (x - self.x) / self.zoom
	local my = (y - self.y) / self.zoom
	return mx, my
end

function Camera:PushCamera()
	love.graphics.push()
	love.graphics.scale( 1/self.zoom, 1/self.zoom )
	love.graphics.translate( -self.x, -self.y )
end

function Camera:PopCamera()
	love.graphics.pop()
end

function Camera:RenderDebug()
	imgui.Text( string.format( "Camera: %.2f, %.2f; Zoom: %.2f", self.x, self.y, self.zoom ))
end


return Camera
