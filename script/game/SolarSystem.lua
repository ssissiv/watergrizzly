class( "SolarSystem", Engine.Entity )

function SolarSystem:OnSpawnEntity( world, parent )
	SolarSystem._base.OnSpawnEntity( self, world, parent )

	self.star = self.world:SpawnEntity( Star:new(), self )
	self.star_field = self.world:SpawnEntity( StarField:new(), self )
end

