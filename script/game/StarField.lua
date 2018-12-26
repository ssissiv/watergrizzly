local StarField = class( "StarField", Engine.Entity )

function StarField:OnSpawnEntity( world, parent )
	StarField._base.OnSpawnEntity( self, world, parent )

	local x1, y1, x2, y2 = world:GetBounds()
	self.stars = {}
	for i = 1, 100 do
		table.insert( self.stars, { x = math.random( x1, x2 ), y = math.random( y1, y2 ) })
	end
end

function StarField:OnRenderEntity()
	love.graphics.setColor( 1, 1, 1 )
	for i, star in ipairs( self.stars ) do
		love.graphics.circle( "fill", star.x, star.y, 2 )
	end
end
