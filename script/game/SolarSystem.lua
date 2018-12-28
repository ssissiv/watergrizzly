class( "SolarSystem", Engine.Entity )

function SolarSystem:OnSpawnEntity( world, parent )
	SolarSystem._base.OnSpawnEntity( self, world, parent )

	self.star = self.world:SpawnEntity( Star:new(), self )
	self.star_field = self.world:SpawnEntity( StarField:new(), self )

	for i = 1, 15 do
		local asteroid = Asteroid:new()
		self.world:SpawnEntity( asteroid, self )
		asteroid:SetOrbitalRadius( math.random( 300, 1000 ))
	end
end

