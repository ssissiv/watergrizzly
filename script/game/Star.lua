local Star = class( "Star", Engine.Entity )

function Star:init()
	Star._base.init( self )
	self.radius = 100
end


function Star:OnSpawnEntity( world, parent )
	Star._base.OnSpawnEntity( self, world, parent )

	self.body = love.physics.newBody( world.physics, 0, 0, "static")
	self.shape = love.physics.newCircleShape( self.radius )
	self.fixture = love.physics.newFixture( self.body, self.shape) -- Attach fixture to body and give it a density of 1.
	self.fixture:setUserData( self )
	self.fixture:setCategory( PHYS_GROUP_OBJECT )
	self.fixture:setMask( PHYS_GROUP_OBJECT )
end

function Star:OnCollide( other, contact )
	local x1, y1 = contact:getPositions()
	self.world:AddExplosion( x1, y1 )
	self.world:DespawnEntity( other )
end

function Star:RenderEntity()
	self:RenderCorona()

	love.graphics.setColor( 1, 1, 0 )
	love.graphics.circle( "fill", 0, 0, self.radius )
end

function Star:RenderCorona()
	local width = math.sin( self.world:GetElapsedTime() * 5 ) * 5 + 10

	love.graphics.setColor( 1, 1, 0, 0.2 )
	love.graphics.circle( "fill", 0, 0, self.radius + width, self.radius + width )
end
