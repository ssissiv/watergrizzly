--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

local mui_defs = require("mui/mui_defs")

local _M = {}

local STATE_NULL = 0
local STATE_PANNING = 1

local ZOOM_FACTOR = 0.2
local ZOOM_MIN = 0.05
local ZOOM_MAX = 4.0

local function panTo( self, x, y )
	if self._easeDriver then
		self._easeDriver:stop()
	end

	self._easeDriver = self._camera:seekLoc( x, y, 0.5 )
end

local function onInputEvent( self, event )
	if event.eventType == mui_defs.EVENT_KeyUp then
		if event.key == mui_defs.K_MINUS then
			local xs, ys = self._camera:getScl()
			if xs < ZOOM_MAX and ys < ZOOM_MAX then
				local xs, ys, zs = self._camera:getScl()
				self._camera:moveScl( xs*ZOOM_FACTOR, ys*ZOOM_FACTOR, 0.2 )
			end
			return true

		elseif event.key == mui_defs.K_PLUS then
			local xs, ys = self._camera:getScl()
			if xs > ZOOM_MIN and ys > ZOOM_MIN then
				local xs, ys, zs = self._camera:getScl()
				self._camera:moveScl( -xs*ZOOM_FACTOR, -ys*ZOOM_FACTOR, 0.2 )
			end
			return true

		end

	elseif self._state == STATE_NULL and event.controlDown then
		if event.eventType == mui_defs.EVENT_MouseDown then
			if self._easeDriver then
				self._easeDriver:stop()
				self._easeDriver = nil
			end

			self._panStart = { wx = event.wx, wy = event.wy }
			self._state = STATE_PANNING
			return true
		end

	elseif self._state == STATE_PANNING then
		if event.eventType == mui_defs.EVENT_MouseMove then
			local x0, y0 = self._layer:wndToWorld2D( self._panStart.wx, self._panStart.wy )
			local x1, y1 = self._layer:wndToWorld2D( event.wx, event.wy )
			self._panStart = { wx = event.wx, wy = event.wy }
			self._camera:moveLoc( x0 - x1, y0 - y1, 0 )
		elseif event.eventType == mui_defs.EVENT_MouseUp then
			self._state = STATE_NULL
		end
	
	end

	return self._state ~= STATE_NULL
end

function _M.createHandler( layer )

	local camera = MOAICamera2D.new ()
	layer:setCamera( camera )
	camera:setScl( 1.5 )
	
	return
	{
		_layer = layer,
		_camera = camera,
		_state = STATE_NULL,
		_panStart = nil,
		_easeDriver = nil,

		onInputEvent = onInputEvent,

		panTo = panTo,
	}	
end

return _M
