class( "Screen", Engine.Entity )

function Screen:UpdateEntity( dt )
	self:UpdateScreen( dt )
end

function Screen:RenderEntity()
	self:RenderScreen()
end

