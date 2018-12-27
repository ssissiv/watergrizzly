local Entity = Engine.Entity

function Entity:GetDistance( other )
	if not self.GetPosition or not other.GetPosition then
		return false
	end

	local x1, y1 = self:GetPosition()
	local x2, y2 = other:GetPosition()
	return Math.Dist( x1, y1, x2, y2 )
end
