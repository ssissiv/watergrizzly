
function World:GetEntitiesInRange( x0, y0, range, t )
	table.clear( t )
	for i, ent in ipairs( self.entities ) do
		-- TODO: use precise entity extents instead of a position
		if ent.GetPosition then
			local x1, y1 = ent:GetPosition()
			if Math.Dist( x0, y0, x1, y1 ) <= range then
				table.insert( t, ent )
			end
		end
	end
end

