local DeepSpace = class( "Location.DeepSpace", Location )

function DeepSpace:GetName()
	return "Deep Space"
end

function DeepSpace:GetShipSpeed()
	return -1000
end

function DeepSpace:RenderLocation( ui )
end

function DeepSpace:UpdateLocation( dt )
end

