-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local util = require( "modules/util" )
local mui_defs = require( "mui/mui_defs" )
local mui_widget = require( "mui/widgets/mui_widget" )
require( "modules/class" )

--------------------------------------------------------
-- Local Functions
--------------------------------------------------------

local mui_button = class( mui_widget )

mui_button.BUTTON_Inactive = 0
mui_button.BUTTON_Active = 1
mui_button.BUTTON_Hover = 2

function mui_button:init( def )
	mui_widget.init( self, MOAIProp2D.new(), def)
	
	self._prop:setBounds( -def.w/2, -def.h/2, 0, def.w/2, def.h/2, 0 )
	self._buttonState = mui_button.BUTTON_Inactive
	self._hotkey = def.hotkey
end

function mui_button:setHotkey( hotkey )
	self._hotkey = hotkey
end

function mui_button:getState()
	return self._buttonState
end

function mui_button:onActivate( screen )
	mui_widget.onActivate( self, screen )
end

function mui_button:onDeactivate( screen )
	mui_widget.onDeactivate( self, screen )
end

function mui_button:handleInputEvent( ev )

	if ev.type == mui_defs.EVENT_KeyDown and ev.key == self._hotkey then
		self:dispatchEvent( { type = mui_defs.EVENT_ButtonClick, widget = self, ie = ev } )
		return true
		
	elseif ev.type == mui_defs.EVENT_MouseDown and ev.button == mui_defs.MB_Left then
		assert( self._prop )
		assert( self._prop:inside( ev.x, ev.y ))
		self._buttonState = mui_button.BUTTON_Active
		ev.widget = self
		self:dispatchEvent( ev )
		return true

	elseif ev.type == mui_defs.EVENT_MouseUp and ev.button == mui_defs.MB_Left then
		ev.widget = self
		self:dispatchEvent( ev )
		if self._buttonState == mui_button.BUTTON_Active then
			self._buttonState = mui_button.BUTTON_Hover
			self:dispatchEvent( { type = mui_defs.EVENT_ButtonClick, widget = self, ie = ev } )
		end
		return true

	elseif ev.type == mui_defs.EVENT_MouseMove then
		if self._prop:inside( ev.x, ev.y ) then
			if self:getScreen():getFocus() ~= self then
				self:getScreen():lockFocus( self )
				self._buttonState = mui_button.BUTTON_Hover
				self:dispatchEvent( { type = mui_defs.EVENT_ButtonEnter, widget = self, ie = ev } )
			end
		elseif self._buttonState == mui_button.BUTTON_Hover then
			self:getScreen():unlockFocus( self )
			self._buttonState = mui_button.BUTTON_Inactive
			self:dispatchEvent( { type = mui_defs.EVENT_ButtonLeave, widget = self, ie = ev } )
		end
		return true
	end
end


return mui_button
