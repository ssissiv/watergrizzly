local MINING_ENERGY = 5.0
local MINING_PERIOD = 3.0

-------------------------------------------------------------

local MiningLaser = class( "Component.MiningLaser", Engine.Component )

function MiningLaser:init()
	MiningLaser._base.init( self )
end

function MiningLaser:OnSpawnEntity( world, parent )
	MiningLaser._base.OnSpawnEntity( self, world, parent )
	world:ListenForEvent( WORLD_EVENT.INPUT, self, self.OnInputEvent )
end

function MiningLaser:OnInputEvent( event_name, input )
	if input.what == Input.KEY_DOWN and input.key == "return" then
		if self.target then
			self:DeactivateMiningLaser()
		else
			local target = self.parent.scanner and self.parent.scanner:GetPrimaryTarget()
			if target and self:CanMine( target ) then
				self:ActivateMiningLaser( self.parent.scanner:GetPrimaryTarget() )
				input.handled = true
			end
		end
	end
end

function MiningLaser:CanMine( target )
	if not target:IsSpawned() then
		return false
	end
	if not is_instance( target, Asteroid ) then
		return false, "Cannot mine this target"
	end
	if target.storage:GetAmount( ITEM.ORE ) <= 0 then
		return false, "No ore available"
	end
	if not self.parent.scanner:IsTarget( target ) then
		return false, "Not a target"
	end
	return true
end

function MiningLaser:ActivateMiningLaser( target )
	self.target = target
	self.particles = Particles.MiningEmitter()
	self.time_left = MINING_PERIOD
end

function MiningLaser:DeactivateMiningLaser()
	self.target = nil
	self.particles = nil
end

function MiningLaser:UpdateMiningLaser( dt, target )
	if not self:CanMine( target ) then
		return false
	end
	if self.parent.energy and not self.parent.energy:ConsumeEnergy( self, MINING_ENERGY * dt ) then
		return false
	end

	self.time_left = self.time_left - dt
	if self.time_left <= 0 then
		-- Cycle complete!
		self.time_left = MINING_PERIOD

		target.storage:TransferTo( self.parent.storage, ITEM.ORE, 1 )

		return self:CanMine( target )
	else
		return true
	end
end

function MiningLaser:OnUpdateEntity( dt )
	if self.target then
		if not self:UpdateMiningLaser( dt, self.target ) then
			self:DeactivateMiningLaser()
		end

		if self.particles then
			self.particles:update( dt )
		end
	end
end

function MiningLaser:OnRenderEntity()
	if self.target then
		local x1, y1 = self.target:GetPosition()
		local x2, y2 = self.parent:GetPosition()

		love.graphics.setColor( 0, 0.5, 1.0 )
		love.graphics.line( x1, y1, x2, y2 )

		local angle = math.atan2( y2 - y1, x2 - x1 )
		local w, h = math.max( math.abs( y2 - y1 ), math.abs( x2 - x1 )), 6
		local alpha = math.sin( self.world:GetElapsedTime() * 4.0 ) * 0.25 + 0.5
		love.graphics.push()
		love.graphics.translate( (x1 + x2)/2, (y1 + y2)/2 )
		love.graphics.rotate( angle )
		love.graphics.setColor( 0, 0.5, 1.0, alpha )
		love.graphics.rectangle( "fill", -w/2, -h/2, w, h )
		love.graphics.pop()

		if self.particles then
			love.graphics.setColor( 1, 1, 1 )
			love.graphics.draw( self.particles, x1, y1 )
		end
	end
end
