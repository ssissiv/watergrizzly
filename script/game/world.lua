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
	
	-- love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	self.physics = love.physics.newWorld( 0, 0, true )
	self.physics:setCallbacks( beginContact, endContact )

	self.systems = {}
	local GRID_SIZE = 10000
	for xgrid = 1, 3 do
		for ygrid = 1, 3 do
			local x, y = GRID_SIZE * (xgrid-1), GRID_SIZE * (ygrid-1)
			x = x + GRID_SIZE/2 + math.random( GRID_SIZE )/2
			y = y + GRID_SIZE/2 + math.random( GRID_SIZE )/2

			local system = SolarSystem:new()
			system:SetPosition( x, y )
			table.insert( self.systems, system )
			self:SpawnEntity( system )
		end
	end

	self.player = Ship:new()
	self:SpawnEntity( self.player )
	local x, y = self.systems[1]:GetPosition()
	self.player:SetPosition( x + 200, y + 200 )
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
	World._base.RenderWorld( self, camera )
	
	love.graphics.setColor( 1, 1, 1 )
	for i, t in ipairs( self.particles ) do
		love.graphics.draw( t.particles, t.x, t.y )
	end
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

