class( "Location" )

function Location:RenderLocation( ui )

end

function Location:__tostring()
	return string.format( "[%s]", self._classname )
end