class( "Screen", Engine.Entity )

function Screen:OnUpdateEntity( dt )
	self:UpdateScreen( dt )
end

function Screen:OnRenderEntity()
	self:RenderScreen()
end

