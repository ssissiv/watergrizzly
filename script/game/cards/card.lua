class( "Card" )

function Card:init()
	self.x = 0
	self.y = 0
	self.w, self.h = 50, 50
	self.hover = false
end

function Card:OnSpawn( world )
	self.world = world
end

function Card:OnDespawn()
	self.world = nil
end

function Card:SetHover( hover )
	self.hover = hover == true
end

function Card:IsHovered()
	return self.hover
end

function Card:RenderCard()

	if self.progress then
		local t = clamp( self.progress / self.duration, 0, 1 )

		local radius = self.w/2
		local cx, cy = self.x + self.w /2, self.y + self.h / 2
		love.graphics.setColor( 255, 220, 220, 255 )
		love.graphics.arc( "fill", cx, cy, radius, -math.pi/2, t * 2 * math.pi - math.pi/2, 24 )

		love.graphics.setColor( 100, 25, 25, 255 )
		love.graphics.circle( "fill", cx, cy, radius - 4 )

		if self.hover then
			love.graphics.setColor( 255, 255, 255, 255 )
		else
			love.graphics.setColor( 200, 50, 50, 255 )
		end
		love.graphics.circle( "line", cx, cy, radius - 4 )
	else

		love.graphics.setColor( 100, 25, 25, 255 )
		love.graphics.rectangle( "fill", self.x, self.y, self.w, self.h )

		if self.hover then
			love.graphics.setColor( 255, 255, 255, 255 )
		else
			love.graphics.setColor( 200, 50, 50, 255 )
		end

		love.graphics.rectangle( "line", self.x, self.y, self.w, self.h )

	end

	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.print( self._classname, self.x, self.y - 12 )
end

function Card:OffsetCard( dx, dy )
	self.x = self.x + (dx or 0)
	self.y = self.y + (dy or 0)
end

function Card:SetPosition( wx, wy )
	self.x, self.y = wx, wy
end

function Card:HitTest( wx, wy )
	if self.progress then
		local radius = self.w/2
		local cx, cy = self.x + self.w /2, self.y + self.h / 2
		return distance( wx, wy, cx, cy ) <= radius
	else
		return wx >= self.x and wx <= self.x + self.w and wy >= self.y and wy <= self.y + self.h
	end
end

function Card:UpdateCard( dt )
	if self.progress then
		self.progress = self.progress + dt
		if self.progress >= self.duration then
			self:CompleteProgress()
		end
	end
end


function Card:CompleteProgress()
	self.progress = nil
	if self.OnCompleteProgress then
		self:OnCompleteProgress()
	end
end

