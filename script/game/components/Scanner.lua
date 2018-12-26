SCAN_RANGE = 150
SCAN_LOSS_TIME = 3.0
SCAN_ACQUIRE_TIME = 1.0

local Scanner = class( "Component.Scanner", Engine.Component )

function Scanner:OnSpawnEntity( world, parent )
	Scanner._base.OnSpawnEntity( self, world, parent )
	world:ListenForEvent( WORLD_EVENT.INPUT, self, self.OnInputEvent )
end

function Scanner:OnInputEvent( event_name, input )
	if input.what == Input.KEY_DOWN then
		if input.key == "tab" and self.targets then
			local idx = table.arrayfind( self.targets, self.primary_target )
			if idx then
				idx = (idx % #self.targets) + 1
			else
				idx = 1
			end
			self:SetPrimaryTarget( self.targets[ idx ] )
			input.handled = true

		elseif input.key == "return" and self.primary_target then
			print( "ACTIVATE", self.primary_target )
		end
	end
end

function Scanner:OnUpdateEntity( dt )
	self.new_entities = self.new_entities or {}
	self.scan_entities = self.scan_entities or {}

	-- Get all objects in range.
	local x, y = self.parent:GetPosition() 
	self.world:GetEntitiesInRange( x, y, SCAN_RANGE, self.new_entities )

	-- Acquire new targets
	for i, ent in ipairs( self.new_entities ) do
		if self.scan_entities[ ent ] == nil and ent ~= self.parent then
			self:AcquireTarget( ent )
		end
	end

	-- Update current targets
	for ent, target in pairs( self.scan_entities ) do
		self:UpdateTarget( target, dt )
	end

end

function Scanner:AcquireTarget( ent )
	local target = { entity = ent, scan_time = SCAN_ACQUIRE_TIME }
	self.scan_entities[ ent ] = target
end

function Scanner:GainTarget( target )
	target.acquire_time = self.world:GetElapsedTime()

	if self.targets == nil then
		self.targets = {}
	end
	table.insert( self.targets, target.entity )

	if self.primary_target == nil then
		self:SetPrimaryTarget( target.entity )
	end
end

function Scanner:GetPrimaryTarget()
	return self.primary_target
end

function Scanner:SetPrimaryTarget( ent )
	self.primary_target = ent
end

function Scanner:LoseTarget( ent )
	print( "LostTarget:", ent )
	self.scan_entities[ ent ] = nil

	if self.targets then
		table.arrayremove( self.targets, ent )
	end
	if self.primary_target == ent then
		self:SetPrimaryTarget( nil )
	end
end

function Scanner:GetTargets()
	return self.targets or table.empty
end

function Scanner:Targets()
	return ipairs( self.targets or table.empty )
end

function Scanner:UpdateTarget( target, dt )
	local x, y = target.entity:GetPosition()
	local x0, y0 = self.parent:GetPosition()
	local now = self.world:GetElapsedTime()

	if Math.Dist( x0, y0, x, y ) > SCAN_RANGE then
		-- Out of scan range: lose targets.
		if target.loss_time == nil then
			target.loss_time = now
		elseif now - target.loss_time > SCAN_LOSS_TIME then
			self:LoseTarget( target.entity )
		end

	else
		target.loss_time = nil
		if target.acquire_time == nil then
			target.scan_time = math.max( 0, target.scan_time - dt )
			if target.scan_time <= 0 then
				self:GainTarget( target )
			end
		end
	end
end

function Scanner:OnRenderEntity()
	local now = self.world:GetElapsedTime()
	local x0, y0 = self.parent:GetPosition()

	for ent, target in pairs( self.scan_entities ) do
		local x, y = target.entity:GetPosition()
		local dist = Math.Dist( x0, y0, x, y )
		if target.acquire_time then
			local txt = loc.format( "LOCKED\n{2} meters", target.scan_time, math.floor( dist ))
			if target.loss_time then
				self:RenderTargetReticule( x, y, txt )
			else
				self:RenderLockedReticule( x, y, txt, ent )
			end
		else
			local txt = loc.format( "{1%.1f}\n{2} meters", target.scan_time, math.floor( dist ))
			self:RenderTargetReticule( x, y, txt )
		end
	end
end

function Scanner:RenderLockedReticule( x, y, txt, entity )
	if entity == self.primary_target then
		love.graphics.setColor( 1, 1, 1 )
	else
		love.graphics.setColor( 0.6, 0.6, 0.6 )
	end

	local size = 55
	love.graphics.rectangle( "line", x - size/2, y - size/2, size, size )

	love.graphics.print( txt, x + size/2, y + size/2 )
end

function Scanner:RenderTargetReticule( x, y, txt )
	local alpha = math.sin( self.world:GetElapsedTime() * 5.0 ) * 0.5 + 0.5
	love.graphics.setColor( 1, 0, 0, alpha )
	local size = 50
	love.graphics.rectangle( "line", x - size/2, y - size/2, size, size )
	size = 55
	love.graphics.rectangle( "line", x - size/2, y - size/2, size, size )

	-- Label.
	love.graphics.setColor( 1, 0.5, 0.5 )
	love.graphics.print( txt, x + size/2, y + size/2 )
end


