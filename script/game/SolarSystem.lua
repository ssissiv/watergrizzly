class( "SolarSystem", Engine.Entity )

function SolarSystem:OnSpawnEntity( world, parent )
	SolarSystem._base.OnSpawnEntity( self, world, parent )

	self.star = self.world:SpawnEntity( Star:new(), self )
	self.star_field = self.world:SpawnEntity( StarField:new(), self )

	for i = 1, 3 do
		local asteroid = Asteroid:new( math.random( 300, 1000 ))
		self.world:SpawnEntity( asteroid, self )
	end
end

