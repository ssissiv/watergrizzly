
-------------------------------------------------

local SpaceStation = class( "SpaceStation", Engine.Entity )

function SpaceStation:init()
	SpaceStation._base.init( self )

	self.radius = 60
end

function SpaceStation:OnSpawnEntity( world, parent )
	SpaceStation._base.OnSpawnEntity( self, world, parent )

	self.storage = world:SpawnEntity( Component.Storage:new(), self )

	self.body = love.physics.newBody( world.physics, 0, 0, "static")
	self.body:setUserData( self )
	self.shape = love.physics.newCircleShape( self.radius )
	self.fixture = love.physics.newFixture( self.body, self.shape ) -- Attach fixture to body and give it a density of 1.
	self.fixture:setCategory( PHYS_GROUP_OBJECT )
end

function SpaceStation:OnDespawnEntity()
	SpaceStation._base.OnDespawnEntity( self )
	self.body:destroy()
end

function SpaceStation:GetPosition()
	return self.body:getPosition()
end

function SpaceStation:SetPosition( x, y )
	self.body:setPosition( x, y )
end

function SpaceStation:GetAABB()
	local x, y = self:GetPosition()
	return x - self.radius, y - self.radius, x + self.radius, y + self.radius
end

function SpaceStation:OnRenderEntity()
	local x, y = self:GetPosition()
	love.graphics.setColor( 0, 0.3, 0.8 )
	love.graphics.circle( "fill", x - 4, y + 4, self.radius )
	love.graphics.setColor( 0.8, 0.8, 0.8 )
	love.graphics.circle( "fill", x, y, self.radius )
	love.graphics.setColor( 0, 0, 0 )
	love.graphics.circle( "fill", x, y, self.radius - 10 )
end
