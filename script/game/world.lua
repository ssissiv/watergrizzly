local World = class( "World" )

function World:init()
	self.elapsed_time = 0
	self.depart_time = 0
	self.world_speed = DEFAULT_WORLD_SPEED
	self.next_id = 1
	self.pause = {}
	self.cards = {}

	self.star_field = StarField:new()

	self.events = EventSystem()
	self.events:ListenForAny( self, self.OnWorldEvent )

	self.scheduled_events = {}

	self:SetLocation( Location.Planet:new( self ))

	self:AddCard( Card.TravelTo( Location.DeepSpace:new( self ) ))
end

function World:ListenForAny( listener, fn, priority )
	self.events:ListenForAny( listener, fn, priority )
end

function World:ListenForEvent( event, listener, fn, priority )
	self.events:ListenForEvent( event, listener, fn, priority )
end

function World:ListenForEvent( event, listener, fn, priority )
	self.events:ListenForEvent( event, listener, fn, priority )
end

function World:RemoveListener( listener )
	self.events:RemoveListener( listener )
end

function World:BroadcastEvent( event_name, ... )
	self.events:BroadcastEvent( event_name, ... )
end

function World:OnWorldEvent( event_name, ... )
	if event_name == WORLD_EVENT.LOG then
		print( "WORLD_EVENT.LOG:", ... )
	end
end

local function CompareScheduledEvents( ev1, ev2 )
	return ev1.when < ev2.when
end

function World:GenerateID()
	self.next_id = self.next_id + 1
	return self.next_id
end

function World:IsGameOver()
	return self.is_gameover == true
end

function World:SetGameOver()
	self.is_gameover = true
end

function World:SetLocation( location )
	self.prev_location = self.location
	self.location = location
	self.depart_time = self.elapsed_time
end

function World:LerpArrival( x1, x2, ease )
	local dt = self.elapsed_time - self.depart_time
	if dt >= 3.0 then
		return x2
	else
		return ease( dt, x1, x2 - x1, 3.0 )
	end
end

function World:Cards()
	return ipairs( self.cards )
end

function World:ScheduleEvent( delta, event_name, ... )
	assert( delta > 0 or error( string.format( "Scheduling in the past: %s with delta %d", event_name, delta )))
	local ev = { when = self.turn + delta, event_name, ... }
	table.binsert( self.scheduled_events, ev, CompareScheduledEvents )
	return ev
end

function World:SchedulePeriodicEvent( delta, event_name, ... )
	local ev = self:ScheduleEvent( delta, event_name, ... )
	ev.period = delta
	return ev
end

function World:UnscheduleEvent( ev )
	ev.cancel = true
end

function World:GetElapsedTime()
	return self.elapsed_time
end

function World:TogglePause( pause_type )
	assert( IsEnum( pause_type, PAUSE_TYPE ))
	local idx = table.arrayfind( self.pause, pause_type )
	if idx then
		table.remove( self.pause, idx )
	else
		table.insert( self.pause, pause_type )
	end
end

function World:IsPaused()
	return #self.pause > 0 or self:IsGameOver() 
end

function World:GetWorldSpeed()
 	return self.world_speed
end

function World:SetWorldSpeed( world_speed )
 	self.world_speed = clamp( world_speed, 0, MAX_WORLD_SPEED )
end

function World:AddCard( card )
	table.insert( self.cards, card )
	card:OnSpawn( self )
end

function World:RemoveCard( card )
	table.arrayremove( self.cards, card )
	card:OnDespawn( self )
end

function World:UpdateWorld( dt )
	if self:IsPaused() then
		return
	end

	self.elapsed_time = self.elapsed_time + (dt * self.world_speed)

	self:UpdateSpeed( dt )

	self.star_field:UpdateStarField( dt )
	self.location:UpdateLocation( dt )

	for i, card in ipairs( self.cards ) do
		card:UpdateCard( dt )
	end
end

function World:UpdateSpeed( dt )
	local start_speed = self.prev_location and self.prev_location:GetShipSpeed() or 0
	local end_speed = self.location and self.location:GetShipSpeed() or 0
	local speed = self:LerpArrival( start_speed, end_speed, easing.inCubic )

	self.star_field:SetSpeed( speed )
end

function World:CheckScheduledEvents()
	-- Broadcast any scheduled events.
	local ev = self.scheduled_events[ 1 ]

	while ev and ev.when <= self.turn do
		table.remove( self.scheduled_events, 1 )

		if not ev.cancel then
			self:BroadcastEvent( table.unpack( ev ) )
		end

		if not ev.cancel then
			if ev.period then
				ev.when = self.turn + ev.period
				table.binsert( self.scheduled_events, ev, CompareScheduledEvents )
			end
		end

		ev = self.scheduled_events[1]
	end
end


function World:RenderWorld( dt, camera )
	self.star_field:RenderStarField()

	self.location:RenderLocation( dt )
	if self.prev_location then
		self.prev_location:RenderLocation( dt )
		local t = self:LerpArrival( 0, 1.0, easing.linear )
		if t >= 1.0 then
			self.prev_location = nil
		end
	end

    camera:PushCamera()
	love.graphics.setColor( 128, 60, 60, 255 )
	love.graphics.line( 0, -10, 0, 10 )
	love.graphics.line( -10, 0, 10, 0 )

	love.graphics.line( CAMERA_BOUNDS_LEFT, CAMERA_BOUNDS_BOTTOM, CAMERA_BOUNDS_LEFT, CAMERA_BOUNDS_TOP )
	love.graphics.line( CAMERA_BOUNDS_LEFT, CAMERA_BOUNDS_TOP, CAMERA_BOUNDS_RIGHT, CAMERA_BOUNDS_TOP )
	love.graphics.line( CAMERA_BOUNDS_RIGHT, CAMERA_BOUNDS_TOP, CAMERA_BOUNDS_RIGHT, CAMERA_BOUNDS_BOTTOM )
	love.graphics.line( CAMERA_BOUNDS_RIGHT, CAMERA_BOUNDS_BOTTOM, CAMERA_BOUNDS_LEFT, CAMERA_BOUNDS_BOTTOM )

	for i, card in ipairs( self.cards ) do
		card:RenderCard()
	end
    camera:PopCamera()
end




