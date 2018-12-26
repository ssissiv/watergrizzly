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

function Ship:GetPosition()
	return self.x, self.y
end

function Ship:UpdateEntity( dt )
	if Input.IsPressed( "space" ) then
		if self.start_thrust == nil then
			self.start_thrust = self.world:GetElapsedTime()
		end
		self.thrust = math.max( 1, math.sqrt( self.world:GetElapsedTime() - self.start_thrust ))
		self.xvel = clamp( self.xvel + self.fwd[1] * self.thrust * dt, -1, 1 )
		self.yvel = clamp( self.yvel + self.fwd[2] * self.thrust * dt, -1, 1 )
	else
		self.start_thrust = nil
		self.thrust = nil
	end

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

	local x1, y1, x2, y2 = self.world:GetBounds()
	self.x = clamp( self.x + self.xvel, x1, x2 )
	self.y = clamp( self.y + self.yvel, y1, y2 )

	if self.thrust then
		self.thrust_particles:moveTo( self.x - self.fwd[1] * 10, self.y - self.fwd[2] * 10 )
		self.thrust_particles:setEmissionRate( 16 )
	else
		self.thrust_particles:setEmissionRate( 0 )
	end
	self.thrust_particles:update( dt )
end

function Ship:OnRenderEntity()
	love.graphics.setColor( 1, 0, 0 )
	love.graphics.draw( self.thrust_particles, 0, 0 )
	love.graphics.translate( self.x, self.y )
	love.graphics.rotate( self.angle )
	love.graphics.polygon( "fill", self.verts )
	love.graphics.rotate( -self.angle )
	love.graphics.translate( -self.x, -self.y )
end
