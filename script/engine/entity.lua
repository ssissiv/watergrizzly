local Entity = class( "Engine.Entity" )

function Entity:init()
end

function Entity:SpawnEntity( parent )
	assert( self.parent == nil )
	self.parent = parent
	if self.OnSpawnEntity then
		self:OnSpawnEntity()
	end
end

function Entity:DespawnEntity()
	if self.OnDespawnEntity then
		self:OnDespawnEntity()
	end
	assert( self.parent )
	self.parent = nil
end

function Entity:__tostring()
	return string.format("<%s>", self._classname )
end
