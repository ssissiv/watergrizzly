local TravelTo = class( "Card.TravelTo", Card )

function TravelTo:init( location )
	Card.init( self, location )
	self.dest = location
	self.progress = 0
	self.duration = 5.0
end

function TravelTo:OnCompleteProgress()
	self.world:SetLocation( self.dest )
	if is_instance( self.dest, Location.Planet ) then
		self.dest = Location.DeepSpace:new( self.world )
	else
		self.dest = Location.Planet:new( self.world )
	end
	self.progress = 0
end
