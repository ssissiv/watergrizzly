local Entity = class( "Engine.Entity" )

function Entity:init()
end

function Entity:OnSpawn( parent )
	assert( self.parent == nil )
	self.parent = parent
end

function Entity:OnDespawn()
	assert( self.parent )
	self.parent = nil
end
