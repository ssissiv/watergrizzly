local StarField = class( "StarField" )

function StarField:init()
	self.stars = {}
	self.max_stars = 100
	self.speed = -1000

	for i = 1, self.max_stars do
		self.stars[i] = self:NewStar( {}, math.random( love.graphics.getWidth() ))
	end
end

function StarField:SetSpeed( speed )
	self.speed = speed
end

function StarField:NewStar( star, x )
	star = star or {}
	star.x = x or love.graphics.getWidth()
	star.y = math.random( love.graphics.getHeight() )
	star.dist = math.random()

	return star
end

function StarField:RenderStarField()
	for i, star in ipairs( self.stars ) do
		local k = 1 + math.log( 1 + math.abs( self.speed ))
		local b = 255 * 4 * star.dist / k
		love.graphics.setColor( b, b, b )
		local w = 1 + k^2 * star.dist
		love.graphics.rectangle( "fill", star.x, star.y, w, 1 )
	end
end

function StarField:UpdateStarField( dt )
	local xmin, xmax = 0, love.graphics.getWidth()
	for i, star in ipairs( self.stars ) do
		star.x = star.x + (dt * self.speed)
		if star.x <= xmin or star.x >= xmax then
			self:NewStar( star )
		end
	end
end
