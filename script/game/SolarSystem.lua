class( "SolarSystem", Engine.Entity )

function SolarSystem:init()
	SolarSystem._base.init( self )
	self.x, self.y = 0, 0
end

function SolarSystem:OnSpawnEntity( world, parent )
	SolarSystem._base.OnSpawnEntity( self, world, parent )

	self.nebula = Render.CreateNebula()

	self.star = self.world:SpawnEntity( Star:new(), self )
	self.star:SetPosition( self:GetPosition() )

	for i = 1, 5 do
		local asteroid = Asteroid:new()
		self.world:SpawnEntity( asteroid, self )
		asteroid:SetOrbitalRadius( self.star, math.random( 300, 1000 ))
	end

	local x1, y1, x2, y2 = self:GetAABB()
	self.station = self.world:SpawnEntity( SpaceStation:new(), self )
	self.station:SetPosition( math.random( x1, x2 ), math.random( y1, y2 ))
end

function SolarSystem:GetPosition()
	return self.x, self.y
end

function SolarSystem:SetPosition( x, y )
	self.x, self.y = x, y
end

function SolarSystem:GetAABB()
	return -1000 + self.x, -1000 + self.y, 1000 + self.x, 1000 + self.y
end

function SolarSystem:RenderEntity()
	local x1, y1, x2, y2 = self:GetAABB()
	-- local x1, y1 = camera:ScreenToWorld( 0, 0 )
	-- local x2, y2 = camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )
	local cx, cy = (x1 + x2)/2, (y1 + y2)/2
	local nw, nh = self.nebula:getWidth(), self.nebula:getHeight()
	-- local dx = x1 - (cx - 1024)
	-- local k = math.log( math.abs(cx) ) * (cx >= 0 and 1.0 or -1.0)
	-- local p = k / (1 + math.abs(k))
	-- love.graphics.draw( self.nebula, cx - 1024, cy - 1024, 0, 2048 / nw, 2048 / nh )
	love.graphics.setColor( 1, 1, 1 )
	love.graphics.draw( self.nebula, x1, y1, 0, (x2 - x1) / nw, (y2 - y1) / nh )

	love.graphics.setColor( 1, 0, 0 )
	love.graphics.rectangle( "line", x1, y1, x2 - x1, y2 - y1 )

	SolarSystem._base.RenderEntity( self )
end