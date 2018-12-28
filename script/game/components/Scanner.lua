local SCAN_RANGE = 150
local SCAN_LOSS_TIME = 3.0
local SCAN_ACQUIRE_TIME = 1.0

-------------------------------------------------------------------

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

function Scanner:IsTarget( target )
	return self.targets and table.arrayfind( self.targets, target )
end

function Scanner:UpdateTarget( target, dt )
	if not target.entity:IsSpawned() then
		self:LoseTarget( target.entity )
		return
	end

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
		if ent:IsSpawned() then
			local x, y = target.entity:GetPosition()
			local dist = Math.Dist( x0, y0, x, y )
			if target.acquire_time then
				local txt = loc.format( "LOCKED\n{2} meters", target.scan_time, math.floor( dist ))
				if target.loss_time then
					self:RenderTargetReticule( target.entity, txt )
				else
					self:RenderLockedReticule( target.entity, txt )
				end
			else
				local txt = loc.format( "{1%.1f}\n{2} meters", target.scan_time, math.floor( dist ))
				self:RenderTargetReticule( target.entity, txt )
			end
		else
			print( "Dead scanned target", ent, ent:IsSpawned() )
		end
	end
end

function Scanner:RenderLockedReticule( entity, txt )
	if entity == self.primary_target then
		love.graphics.setColor( 1, 1, 1 )
	else
		love.graphics.setColor( 0.6, 0.6, 0.6 )
	end

	local x1, y1, x2, y2 = entity:GetAABB()
	love.graphics.rectangle( "line", x1 - 2, y1 - 2, x2 - x1 + 2, y2 - y1 + 2 )
	love.graphics.rectangle( "line", x1 - 4, y1 - 4, x2 - x1 + 4, y2 - y1 + 4 )

	love.graphics.print( txt, x1, y2 + 4 )
end

function Scanner:RenderTargetReticule( entity, txt )
	local alpha = math.sin( self.world:GetElapsedTime() * 5.0 ) * 0.5 + 0.5
	love.graphics.setColor( 1, 0, 0, alpha )

	local x1, y1, x2, y2 = entity:GetAABB()
	love.graphics.rectangle( "line", x1 - 2, y1 - 2, x2 - x1 + 2, y2 - y1 + 2 )
	love.graphics.rectangle( "line", x1 - 4, y1 - 4, x2 - x1 + 4, y2 - y1 + 4 )

	-- Label.
	love.graphics.setColor( 1, 0.5, 0.5 )
	love.graphics.print( txt, x1, y2 + 4 )
end


