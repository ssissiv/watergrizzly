local World = class( "World", Engine.World )

function World:init()
	World._base.init( self )

	self.system = SolarSystem:new()
	self:SpawnEntity( self.system )

	self.player = Ship:new()
	self:SpawnEntity( self.player )
end

function World:OnUpdateWorld( dt )
end

function World:OnRenderWorld( dt, camera )
end




