local World = class( "World", Engine.World )

local function beginContact( fixture1, fixture2, contact )
	local ent1, ent2 = fixture1:getBody():getUserData(), fixture2:getBody():getUserData()

	local damage = Combat.CalculateDamageFromImpact( contact )
	ent1.world:QueueEvent( WORLD_EVENT.COLLISION, ent1, ent2, damage )
end

local function endContact( fixture1, fixture2, contact )
end

function World:init()
	World._base.init( self )

	self.particles = {}

	Shaders.nebula:send( "density", 0.15 )
	Shaders.nebula:send( "falloff", 4.0 )
	Shaders.nebula:send( "scale", 0.5 )
	Shaders.nebula:send( "offset", { math.random() * 100, math.random() * 100 } )
	Shaders.nebula:send( "tint", { math.random(), math.random(), math.random() } )

	-- love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	self.physics = love.physics.newWorld( 0, 0, true )
	self.physics:setCallbacks( beginContact, endContact )

	self.system = SolarSystem:new()
	self:SpawnEntity( self.system )

	self.player = Ship:new()
	self:SpawnEntity( self.player )

	self.station = SpaceStation:new()
	self:SpawnEntity( self.station )
end

function World:ResetWorld()
	self.physics:destroy()
	self.physics = nil
end

function World:GetPlayer()
	if self.player and self.player:IsSpawned() then
		return self.player
	end
end

function World:OnWorldEvent( event_name, ... )
	if event_name == WORLD_EVENT.COLLISION then
		local ent1, ent2, damage = ...
		if ent1.OnDamage then
			ent1:OnDamage( damage, DAMAGE_TYPE.KINETIC )
		end
		if ent2.OnDamage then
			ent2:OnDamage( damage, DAMAGE_TYPE.KINETIC )
		end
	end

	World._base.OnWorldEvent( self, event_name, ... )
end

function World:OnUpdateWorld( dt )
	self.physics:update( dt )

	for i = #self.particles, 1, -1 do
		local t = self.particles[ i ]
		t.particles:update( dt )
		if not t.particles:isActive() and t.particles:getCount() == 0 then
			table.remove( self.particles, i )
		end
	end
end

function World:RenderWorld( camera )
	love.graphics.setShader( Shaders.nebula )
	local x1, y1 = camera:ScreenToWorld( 0, 0 )
	local x2, y2 = camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )
	love.graphics.rectangle( "fill", x1, y1, x2 - x1, y2 - y1 )
	love.graphics.setShader()

	World._base.RenderWorld( self, camera )
	
	love.graphics.setColor( 1, 1, 1 )
	for i, t in ipairs( self.particles ) do
		love.graphics.draw( t.particles, t.x, t.y )
	end
end

function World:GetBounds()
	return -1000, -1000, 1000, 1000
end


function World:AddExplosion( x, y )
	local ps = love.graphics.newParticleSystem( Assets.IMGS.PARTICLE, 64 )
	ps:setParticleLifetime(2, 3)
	ps:setSpeed( 50, 200 )
	ps:setEmissionArea( "uniform", 10, 10, 0 )
	ps:setSizes( 0.2 )
	ps:setLinearDamping( 2 )
	ps:setColors( 1, 1, 0, 1, 0.5, 0, 0, 1, 0.5, 0.5, 0.5, 0 )
	ps:setEmitterLifetime( 1.0 )
	ps:setSpin( 0, 2 * math.pi )
	ps:setSpread( 2 * math.pi )
	ps:emit( 64 )
	table.insert( self.particles, { particles = ps, x = x, y = y })
end


------------------------------------------------------------------------
-- Input

function World:MousePressed( mx, my, btn )
	local input = { what = Input.MOUSE_DOWN, btn = btn, mx = mx, my = my, handled = false }
	self:BroadcastEvent( WORLD_EVENT.INPUT, input )
	return input.handled
end

function World:MouseReleased( mx, my, btn )
	local input = { what = Input.MOUSE_UP, btn = btn, mx = mx, my = my, handled = false }
	self:BroadcastEvent( WORLD_EVENT.INPUT, input )
	return input.handled
end

function World:KeyPressed( key )
	local input = { what = Input.KEY_DOWN, key = key, handled = false }
	self:BroadcastEvent( WORLD_EVENT.INPUT, input )
	return input.handled
end

function World:KeyReleased( key )
	local input = { what = Input.KEY_UP, key = key, handled = false }
	self:BroadcastEvent( WORLD_EVENT.INPUT, input )
	return input.handled
end

