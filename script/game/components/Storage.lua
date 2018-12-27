
-------------------------------------------------------------------

local Storage = class( "Component.Storage", Engine.Component )

function Storage:init()
	Storage._base.init( self )
	self.items = {}
end

function Storage:AddItem( id, amount )
	amount = amount or 1
	assert( amount >= 0 )
	self.items[ id ] = (self.items[ id ] or 0) + amount
end

function Storage:RemoveItem( id, amount )
	amount = amount or 1
	assert( amount >= 0 )
	self.items[ id ] = math.max( (self.items[ id ] or 0) - amount, 0 )
end

function Storage:GetAmount( id )
	return self.items[ id ] or 0
end

function Storage:TransferTo( storage, id, amount )
	local delta = math.min( self.items[ id ] or 0, amount )
	if delta >= amount then
		self:RemoveItem( id, delta )
		storage:AddItem( id, delta )
	end

	return false
end

function Storage:Items()
	return pairs( self.items )
end
