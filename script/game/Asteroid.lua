local Asteroid = class ( "Asteroid", Engine.Entity )

function Asteroid:init( radius )
	Asteroid._base.init( self )

	self.radius = radius or math.random( 10, 25 )
	self.verts = {}
	for i = 1, 8 do
		local x, y = self.radius * math.cos( i * 2 * math.pi / 8 ), self.radius * math.sin( i * 2 * math.pi / 8 )
		x = x + x * math.random() * 0.4 + 0.8
		y = y + y * math.random() * 0.4 + 0.8
		table.insert( self.verts, x )
		table.insert( self.verts, y )
	end
end

function Asteroid:GetPosition()
	return self.body:getPosition()
end

function Asteroid:SetPosition( x, y )
	self.body:setPosition( x, y )
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

function Asteroid:SetOrbitalRadius( orbital_entity, orbital_radius )
	self.orbital_entity = orbital_entity
	self.orbital_radius = orbital_radius

	if self.orbital_radius then
		local orbital_angle = math.random() * 2 * math.pi
		local x0, y0 = orbital_entity:GetPosition()
		local x1 = x0 + math.cos( orbital_angle ) * self.orbital_radius
		local y1 = y0 + math.sin( orbital_angle ) * self.orbital_radius
		self.body:setPosition( x1, y1 )
		local nx, ny = Math.Normalize( (y1 - y0), -(x1 - x0) )
		self.body:setLinearVelocity( nx * 100, ny * 100 )
	end
end

function Asteroid:OnSpawnEntity( world, parent )
	Asteroid._base.OnSpawnEntity( self, world, parent )

	self.storage = world:SpawnEntity( Component.Storage:new(), self )
	self.storage:AddItem( ITEM.ORE, math.random( 3, 10 ))

	self.body = love.physics.newBody( world.physics, 0, 0, "dynamic")
	self.body:setUserData( self )
	self.body:setMass( 0.1 )
	self.shape = love.physics.newPolygonShape( table.unpack( self.verts ) )
	self.fixture = love.physics.newFixture( self.body, self.shape, 1.0) -- Attach fixture to body and give it a density of 1.
	self.fixture:setCategory( PHYS_GROUP_OBJECT )
	-- self.fixture:setMask( PHYS_GROUP_OBJECT )
end

function Asteroid:OnDespawnEntity()
	Asteroid._base.OnDespawnEntity( self )
	self.body:destroy()
end

function Asteroid:OnDamage( damage, damage_type )
	if not self:IsSpawned() then
		return
	end
	
	if damage > 100 then
		local x1, y1 = self:GetPosition()

		if self.radius / 2 >= 10 then
			local speed = math.max( 10, Math.Length( self.body:getLinearVelocity() ))
			local vx, vy = Math.RandomDirection()
			local fragment = self.world:SpawnEntity( Asteroid:new( self.radius / 2 ) )
			fragment:SetPosition( x1 + vx * self.radius, y1 + vy * self.radius )
			fragment.body:setLinearVelocity( vx * speed, vy * speed )

			local vx, vy = Math.RandomDirection()
			local fragment = self.world:SpawnEntity( Asteroid:new( self.radius / 2 ) )
			fragment:SetPosition( x1 + vx * self.radius, y1 + vy * self.radius )
			fragment.body:setLinearVelocity( vx * speed, vy * speed )
		end

		self.world:AddExplosion( x1, y1 )
		self.world:DespawnEntity( self )
	end	
end

function Asteroid:OnUpdateEntity( dt )
	if self.orbital_radius then
		local x0, y0 = self.orbital_entity:GetPosition()
		local x1, y1 = self:GetPosition()
		local r = Math.Dist( x0, y0, x1, y1 )
		local force = 10000 * self.body:getMass() / r
		-- local nx, ny = Math.Normalize( y, -x )
		self.fx, self.fy = (x0 - x1) * force * dt, (y0 - y1) * force * dt 
		self.body:applyForce( self.fx, self.fy )
	end
end

function Asteroid:OnRenderEntity()
	love.graphics.setColor( 0.6, 0.6, 0.6 )
	love.graphics.polygon("fill", self.body:getWorldPoints( table.unpack( self.verts )))
end