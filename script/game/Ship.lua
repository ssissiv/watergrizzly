local Ship = class( "Ship", Engine.Entity )

function Ship:init()
	Ship._base.init( self )
	self.x, self.y = 300, 300
	self.fwd = { 1, 0 }
	self.verts = { 10, 0, -10, -10, -10, 10 }
end

function Ship:UpdateEntity( dt )
end

function Ship:RenderEntity()
	love.graphics.setColor( 1, 0, 0 )
	love.graphics.translate( self.x, self.y )
	love.graphics.polygon( "fill", self.verts )
	love.graphics.translate( -self.x, -self.y )
end
