
local EnergyGenerator = class( "Component.EnergyGenerator", Engine.Component )

function EnergyGenerator:init()
	EnergyGenerator._base.init( self )
	self.max_amount = 100
	self.amount = self.max_amount
end

function EnergyGenerator:ConsumeEnergy( entity, amount )
	if amount <= self.amount then
		self:DeltaEnergy( -amount )
		return true
	else
		return false
	end
end

function EnergyGenerator:DeltaEnergy( amount )
	self.amount = clamp( self.amount + amount, 0, self.max_amount )
end

function EnergyGenerator:GetPercent()
	return self.amount / self.max_amount
end

function EnergyGenerator:OnUpdateEntity( dt )
	if self.amount < self.max_amount then
		self:DeltaEnergy( 1.0 * dt )
	end
end
