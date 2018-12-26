local World = class( "World", Engine.World )

function World:init()
	World._base.init( self )

	self.system = SolarSystem:new()
	self:SpawnEntity( self.system )

	self.player = Ship:new()
	self:SpawnEntity( self.player )
end

function World:OnUpdateWorld( dt )
end

function World:OnRenderWorld( dt, camera )
	local x1, y1, x2, y2 = self:GetBounds()
	love.graphics.setColor( 0.5, 0, 0 )
	love.graphics.rectangle( "line", x1, y1, x2 - x1, y2 - y1 )
end

function World:GetBounds()
	return -1000, -1000, 1000, 1000
end

------------------------------------------------------------------------
-- Input

function World:MousePressed( mx, my, btn )
end

function World:MouseReleased( mx, my, btn )
end

function World:KeyPressed( key )
end

function World:KeyReleased( key )
end
