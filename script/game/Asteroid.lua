local Asteroid = class ( "Asteroid", Engine.Entity )

function Asteroid:init( orbital_radius )
	Asteroid._base.init( self )
	self.orbital_radius = orbital_radius
	self.orbital_angle = math.random() * 2 * math.pi
	self.orbital_velocity = 100 / self.orbital_radius

	local radius = math.random( 10, 25 )
	self.verts = {}
	for i = 1, 8 do
		local x, y = radius * math.cos( i * 2 * math.pi / 8 ), radius * math.sin( i * 2 * math.pi / 8 )
		x = x + x * math.random() * 0.6 + 0.7
		y = y + y * math.random() * 0.6 + 0.7
		table.insert( self.verts, x )
		table.insert( self.verts, y )
	end
end

function Asteroid:OnUpdateEntity( dt )
	self.orbital_angle = self.orbital_angle + dt * self.orbital_velocity
end

function Asteroid:OnRenderEntity()
	love.graphics.setColor( 0.6, 0.6, 0.6 )
	local x, y = math.cos( self.orbital_angle ) * self.orbital_radius, math.sin( self.orbital_angle ) * self.orbital_radius
	love.graphics.translate( x, y )
	love.graphics.polygon( "fill", self.verts )
	love.graphics.translate( -x, -y )
end