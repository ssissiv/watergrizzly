local Star = class( "Star", Engine.Entity )

function Star:init()
	Star._base.init( self )
	self.radius = 100
	self.x, self.y = 0, 0
end

function Star:GetPosition()
	return self.x, self.y
end

function Star:SetPosition( x, y )
	self.x, self.y = x, y
end

function Star:GetAABB()
	return -self.radius, -self.radius, self.radius, self.radius
end

function Star:OnSpawnEntity( world, parent )
	Star._base.OnSpawnEntity( self, world, parent )

	self.body = love.physics.newBody( world.physics, 0, 0, "static")
	self.body:setUserData( self )
	self.body:setPosition( self.x, self.y )
	self.shape = love.physics.newCircleShape( self.radius )
	self.fixture = love.physics.newFixture( self.body, self.shape) -- Attach fixture to body and give it a density of 1.
	self.fixture:setCategory( PHYS_GROUP_OBJECT )
	-- self.fixture:setMask( PHYS_GROUP_OBJECT )
end

function Star:RenderEntity()
	self:RenderCorona()

	love.graphics.setColor( 1, 1, 0 )
	love.graphics.circle( "fill", self.x, self.y, self.radius )
end

function Star:RenderCorona()
	local width = math.sin( self.world:GetElapsedTime() * 5 ) * 5 + 10

	love.graphics.setColor( 1, 1, 0, 0.2 )
	love.graphics.circle( "fill", self.x, self.y, self.radius + width, self.radius + width )
end
