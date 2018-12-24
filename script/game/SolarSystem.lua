class( "SolarSystem", Engine.Entity )

function SolarSystem:init()
	self.star = Star:new()
end

function SolarSystem:OnSpawnEntity()
	self.parent:SpawnEntity( self.star )
end

function SolarSystem:RenderEntity()
end
