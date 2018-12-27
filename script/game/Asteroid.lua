local Asteroid = class ( "Asteroid", Engine.Entity )

function Asteroid:init( orbital_radius )
	Asteroid._base.init( self )
	self.orbital_radius = orbital_radius
	self.orbital_angle = math.random() * 2 * math.pi
	self.orbital_velocity = 100 / self.orbital_radius

	self.radius = math.random( 10, 25 )
	self.verts = {}
	for i = 1, 8 do
		local x, y = self.radius * math.cos( i * 2 * math.pi / 8 ), self.radius * math.sin( i * 2 * math.pi / 8 )
		x = x + x * math.random() * 0.6 + 0.7
		y = y + y * math.random() * 0.6 + 0.7
		table.insert( self.verts, x )
		table.insert( self.verts, y )
	end
end

function Asteroid:GetPosition()
	return self.body:getPosition()
end

function Asteroid:GetAABB()
	local dx, dy = self:GetPosition()
	local x1, y1, x2, y2 = math.huge, math.huge, -math.huge, -math.huge
	for i = 1, #self.verts, 2 do
		local x, y = self.verts[i], self.verts[i+1]
		x1 = math.min( x, x1 )
		x2 = math.max( x, x2 )
		y1 = math.min( y, y1 )
		y2 = math.max( y, y2 )
	end
	return x1 + dx, y1 + dy, x2 + dx, y2 + dy
end

function Asteroid:OnSpawnEntity( world, parent )
	Asteroid._base.OnSpawnEntity( self, world, parent )

	self.storage = world:SpawnEntity( Component.Storage:new(), self )
	self.storage:AddItem( ITEM.ORE, math.random( 3, 10 ))

	self.body = love.physics.newBody( world.physics, 0, 0, "dynamic")
	self.body:setUserData( self )
	self.shape = love.physics.newPolygonShape( table.unpack( self.verts ) )
	self.fixture = love.physics.newFixture( self.body, self.shape, 1.0) -- Attach fixture to body and give it a density of 1.
	self.fixture:setCategory( PHYS_GROUP_OBJECT )
	self.fixture:setMask( PHYS_GROUP_OBJECT )

	local x, y = math.cos( self.orbital_angle ) * self.orbital_radius, math.sin( self.orbital_angle ) * self.orbital_radius
	self.body:setPosition( x, y )
	self.body:setMass( 0.1 )
	local nx, ny = Math.Normalize( y, -x )
	self.body:setLinearVelocity( nx * 100, ny * 100 )

end

function Asteroid:OnCollide( other, contact )
	local nx, ny = contact:getNormal()

	-- Other body contributes the component of their velocity aligned with the normal
	local vx1, vy1 = other.body:getLinearVelocity()
	local speed1 = Math.Length( vx1, vy1 )
	local impact1 = Math.Dot( vx1 / speed1, vy1 / speed1, nx, ny ) * speed1

	-- Ditto for our body, but with opposite sign (since the normal points away from us)
	local vx2, vy2 = self.body:getLinearVelocity()
	local speed2 = Math.Length( vx2, vy2 )
	local impact2 = Math.Dot( vx2 / speed2, vy2 / speed2, nx, ny ) * speed2

	local impact = impact2 - impact1
	if impact > 100 then
		self.world:DespawnEntity( other )
		local x1, y1 = contact:getPositions()
		self.world:AddExplosion( x1, y1 )
	end
end

function Asteroid:OnUpdateEntity( dt )
	self.orbital_angle = self.orbital_angle + dt * self.orbital_velocity

	-- local x, y = math.cos( self.orbital_angle ) * self.orbital_radius, math.sin( self.orbital_angle ) * self.orbital_radius
	-- self.body:setPosition( x, y )
 --    self.body:setLinearVelocity(0, 0)
	local x, y = self:GetPosition()
	local r = Math.Dist( 0, 0, x, y )
	local force = 10000 * self.body:getMass() / r
	-- local nx, ny = Math.Normalize( y, -x )
	self.body:applyForce( -x * force * dt, -y * force * dt )
end

function Asteroid:OnRenderEntity()
	love.graphics.setColor( 0.6, 0.6, 0.6 )
	love.graphics.polygon("fill", self.body:getWorldPoints( table.unpack( self.verts )))
end