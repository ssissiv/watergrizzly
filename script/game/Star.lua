local Star = class( "Star", Engine.Entity )

function Star:init()
	Star._base.init( self )
	self.dt = 0
end

function Star:UpdateEntity( dt )
	self.dt = self.dt + dt
end

function Star:RenderEntity()
	self:RenderCorona()

	love.graphics.setColor( 1, 1, 0 )
	love.graphics.circle( "fill", 100, 100, 100, 100 )
end

function Star:RenderCorona()
	local width = math.sin( self.dt * 5 ) * 5 + 10

	love.graphics.setColor( 1, 1, 0, 0.2 )
	love.graphics.circle( "fill", 100, 100, 100 + width, 100 + width )
end
