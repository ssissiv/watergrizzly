local Entity = class( "Engine.Entity" )

function Entity:init()
end

function Entity:IsSpawned()
	return self.world ~= nil
end

function Entity:OnSpawnEntity( world, parent )
	assert( world and self.world == nil )
	self.world = world

	if parent then
		assert( is_instance( parent, Engine.Entity ))
		assert( parent:IsSpawned() )
		assert( self.parent == nil )

		self.parent = parent
		if parent.children == nil then
			parent.children = {}
		end
		table.insert( parent.children, self )
	end
end

function Entity:OnDespawnEntity()
	while self.children and #self.children > 0 do
		self.world:DespawnEntity( self.children[ #self.children ] )
	end

	if self.parent then
		table.arrayremove( self.parent.children, self )
		if #self.parent.children == 0 then
			self.parent.children = nil
		end
		self.parent = nil
	end
	self.world = nil
end


function Entity:UpdateEntity( dt )
	if self.children then
		for i = 1, #self.children do
			self.children[i]:UpdateEntity( dt )
		end
	end
	if self.OnUpdateEntity then
		self:OnUpdateEntity( dt )
	end
end

function Entity:RenderEntity()
	if self.children then
		for i = 1, #self.children do
			self.children[i]:RenderEntity()
		end
	end
	if self.OnRenderEntity then
		self:OnRenderEntity()
	end
end

function Entity:__tostring()
	return string.format("<%s>", self._classname )
end
