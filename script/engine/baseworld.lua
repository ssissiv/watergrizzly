local BaseWorld = class( "Engine.World" )

function BaseWorld:init()
	self.elapsed_time = 0
	self.depart_time = 0
	self.world_speed = DEFAULT_WORLD_SPEED
	self.next_id = 1
	self.pause = {}

	self.events = EventSystem()
	self.events:ListenForAny( self, self.OnBaseWorldEvent )

	self.scheduled_events = {}
	self.entities = {}
end

function BaseWorld:ListenForAny( listener, fn, priority )
	self.events:ListenForAny( listener, fn, priority )
end

function BaseWorld:ListenForEvent( event, listener, fn, priority )
	self.events:ListenForEvent( event, listener, fn, priority )
end

function BaseWorld:ListenForEvent( event, listener, fn, priority )
	self.events:ListenForEvent( event, listener, fn, priority )
end

function BaseWorld:RemoveListener( listener )
	self.events:RemoveListener( listener )
end

function BaseWorld:BroadcastEvent( event_name, ... )
	self.events:BroadcastEvent( event_name, ... )
end

function BaseWorld:OnBaseWorldEvent( event_name, ... )
	if event_name == BaseWorld_EVENT.LOG then
		print( "BaseWorld_EVENT.LOG:", ... )
	end
end

local function CompareScheduledEvents( ev1, ev2 )
	return ev1.when < ev2.when
end

function BaseWorld:GenerateID()
	self.next_id = self.next_id + 1
	return self.next_id
end

function BaseWorld:IsGameOver()
	return self.is_gameover == true
end

function BaseWorld:SetGameOver()
	self.is_gameover = true
end

function BaseWorld:ScheduleEvent( delta, event_name, ... )
	assert( delta > 0 or error( string.format( "Scheduling in the past: %s with delta %d", event_name, delta )))
	local ev = { when = self.turn + delta, event_name, ... }
	table.binsert( self.scheduled_events, ev, CompareScheduledEvents )
	return ev
end

function BaseWorld:SchedulePeriodicEvent( delta, event_name, ... )
	local ev = self:ScheduleEvent( delta, event_name, ... )
	ev.period = delta
	return ev
end

function BaseWorld:UnscheduleEvent( ev )
	ev.cancel = true
end

function BaseWorld:GetElapsedTime()
	return self.elapsed_time
end

function BaseWorld:TogglePause( pause_type )
	assert( IsEnum( pause_type, PAUSE_TYPE ))
	local idx = table.arrayfind( self.pause, pause_type )
	if idx then
		table.remove( self.pause, idx )
	else
		table.insert( self.pause, pause_type )
	end
end

function BaseWorld:IsPaused()
	return #self.pause > 0 or self:IsGameOver() 
end

function BaseWorld:GetBaseWorldSpeed()
 	return self.world_speed
end

function BaseWorld:SetBaseWorldSpeed( world_speed )
 	self.world_speed = clamp( world_speed, 0, MAX_world_speed )
end

function BaseWorld:UpdateBaseWorld( dt )
	if self:IsPaused() then
		return
	end

	self.elapsed_time = self.elapsed_time + (dt * self.world_speed)
end

function BaseWorld:CheckScheduledEvents()
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

function BaseWorld:RenderBaseWorld( dt, camera )
end

function BaseWorld:SpawnEntity( entity )
	table.insert( self.entities, entity )
	entity:OnSpawn( self )
end

function BaseWorld:DespawnEntity( entity )
	entity:OnDespawn( self )
	table.arrayremove( self.entities, entity )
end



