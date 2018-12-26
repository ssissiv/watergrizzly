local Ship = class( "Ship", Engine.Entity )

function Ship:init()
	Ship._base.init( self )
	self.x, self.y = 300, 300
	self.fwd = { 1, 0 }
	self.angle = 0
	self.xvel, self.yvel = 0, 0
	self.verts = { 10, 0, -10, -5, -10, 5 }

	local ps = love.graphics.newParticleSystem( Assets.IMGS.PARTICLE, 32 )
	ps:setParticleLifetime(1,2)
	ps:setSizes( 0.1 )
	ps:setColors(  1, 0, 0, 1, 1, 0, 0, 0 )
	ps:setEmissionArea( "uniform", 10, 10, 0 )
	-- ps:setSpeed( 2 )
	-- ps:setLinearAcceleration(-20, -5, 0, 0)

	self.thrust_particles = ps
end

function Ship:OnSpawnEntity( world, parent )
	Ship._base.OnSpawnEntity( self, world, parent )

	self.scanner = world:SpawnEntity( Component.Scanner:new(), self )
	self.energy = world:SpawnEntity( Component.EnergyGenerator:new(), self )

	self.body = love.physics.newBody( world.physics, 0, 0, "dynamic")
	self.body:setUserData( self )
	self.shape = love.physics.newPolygonShape( table.unpack( self.verts ) )
	self.fixture = love.physics.newFixture( self.body, self.shape ) -- Attach fixture to body and give it a density of 1.
	self.fixture:setCategory( PHYS_GROUP_PLAYER )
	self.body:setMass( 0.01 )
	self.body:setPosition( 200, 200 )

	world:ListenForEvent( WORLD_EVENT.INPUT, self, self.OnInputEvent )
end

function Ship:OnDespawnEntity()
	Ship._base.OnDespawnEntity( self )
	self.body:destroy()
end

function Ship:GetPosition()
	return self.x, self.y
end

function Ship:OnUpdateEntity( dt )
	self:UpdateControls( dt )
end

function Ship:OnInputEvent( event_name, input )
	if input.what == Input.KEY_DOWN then
		if input.key == "space" then
			self.body:setLinearDamping( 5 )

		elseif input.key == "up" then
			self.is_thrusting = true
		end

	elseif input.what == Input.KEY_UP then
		if input.key == "space" then
			self.body:setLinearDamping( 0 )

		elseif input.key == "up" then
			self.is_thrusting = nil
		end
	end
end

function Ship:UpdateControls( dt )
	if Input.IsPressed( "left" ) then
		local da = math.pi * dt
		self.angle = self.angle - da
		self.fwd = { math.cos( self.angle ), math.sin( self.angle )}
	end

	if Input.IsPressed( "right" ) then
		local da = math.pi * dt
		self.angle = self.angle + da
		self.fwd = { math.cos( self.angle ), math.sin( self.angle )}
	end

	if self.is_thrusting then
		if self.energy:ConsumeEnergy( self, 10 * dt ) then
			self.body:applyForce( self.fwd[1] * 1000 * dt , self.fwd[2] * 1000 * dt )

			self.thrust_particles:moveTo( self.x - self.fwd[1] * 10, self.y - self.fwd[2] * 10 )
			self.thrust_particles:setEmissionRate( 16 )
		end
	else
		self.thrust_particles:setEmissionRate( 0 )
	end
	self.thrust_particles:update( dt )
end

function Ship:OnRenderEntity()
	self.x, self.y = self.body:getX(), self.body:getY()
	love.graphics.setColor( 1, 0, 0 )
	love.graphics.draw( self.thrust_particles, 0, 0 )
	love.graphics.translate( self.x, self.y )
	love.graphics.rotate( self.angle )
	love.graphics.polygon( "fill", self.verts )
	love.graphics.rotate( -self.angle )
	love.graphics.translate( -self.x, -self.y )
end
