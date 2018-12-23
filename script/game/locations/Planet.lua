local Planet = class( "Location.Planet", Location )

function Planet:init( world )
	self.world = world
end

function Planet:GetName()
	return "Planet X"
end

function Planet:GetShipSpeed()
	return 0
end

function Planet:RenderLocation( ui )
	local radius
	if self.world.location == self and self.world.prev_location then
		radius = self.world:LerpArrival( 0, 300, easing.outCubic )
	elseif self.world.prev_location == self then
		radius = self.world:LerpArrival( 300, 0, easing.outCubic )
	else
		radius = 300
	end

	love.graphics.setColor( 0, 180, 100, 255 )
	love.graphics.circle( "fill", 100, 100, radius, 24 )
end

function Planet:UpdateLocation( dt )
end
