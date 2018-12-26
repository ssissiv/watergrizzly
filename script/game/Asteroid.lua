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

function Asteroid:OnSpawnEntity( world, parent )
	Asteroid._base.OnSpawnEntity( self, world, parent )

	self.body = love.physics.newBody( world.physics, 0, 0, "kinematic")
	self.body:setUserData( self )
	self.shape = love.physics.newPolygonShape( table.unpack( self.verts ) )
	self.fixture = love.physics.newFixture( self.body, self.shape, 1.0) -- Attach fixture to body and give it a density of 1.
	self.fixture:setCategory( PHYS_GROUP_OBJECT )
	self.fixture:setMask( PHYS_GROUP_OBJECT )

	local x, y = math.cos( self.orbital_angle ) * self.orbital_radius, math.sin( self.orbital_angle ) * self.orbital_radius
	self.body:setPosition( x, y )
end

function Asteroid:OnCollide( other, contact )
	local vx, vy = other.body:getLinearVelocity()
	local nx, ny = contact:getNormal()
	vx, vy = nx * vx, ny * vy
	if Math.Length( vx, vy ) > 100 then
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
end

function Asteroid:OnRenderEntity()
	love.graphics.setColor( 0.6, 0.6, 0.6 )
	love.graphics.polygon("fill", self.body:getWorldPoints( table.unpack( self.verts )))
end