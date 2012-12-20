--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

module ( "inputmgr", package.seeall )

local mui_defs = require("mui/mui_defs")
local mui = require("mui/mui")
local array = require("modules/array")

local _M =
{
	_listeners = {},
	_keysDown = {},

	-- Current mouse window coordinates
	_mouseX = nil,
	_mouseY = nil,
}

----------------------------------------------------------------
----------------------------------------------------------------
-- variables
----------------------------------------------------------------

local function createInputEvent( event )
	event.wx, event.wy = _M._mouseX, _M._mouseY
	event.type = event.eventType
	event.controlDown = _M._keysDown[mui_defs.K_CONTROL]
	event.shiftDown = _M._keysDown[mui_defs.K_SHIFT]
	event.altDown = _M._keysDown[mui_defs.K_ALT]

	return event
end

local function notifyListeners( event )

	for i,v in pairs(_M._listeners) do
		local result = v:onInputEvent( event )
		if result ~= nil then
			return result
		end
	end
	
	return nil
end

function addListener( listener )
	assert( array.find(_M._listeners, listener) == nil )
	assert( type(listener.onInputEvent) == "function" )

	table.insert( _M._listeners, listener )
end

function removeListener( listener )
	assert( array.find(_M._listeners, listener) ~= nil )
	
	array.removeElement( _M._listeners, listener )
end

local function onKeyboard( key, down )

	local ev
	if down == true then
		_M._keysDown[key] = true
		ev = createInputEvent( { eventType = mui_defs.EVENT_KeyDown, key = key } )
	else
		_M._keysDown[key] = nil
		ev = createInputEvent( { eventType = mui_defs.EVENT_KeyUp, key = key } )
	end
	if not mui.handleInputEvent( ev ) then
		notifyListeners( ev )
	end
end

local function onMouseMove( x, y )
	_M._mouseX, _M._mouseY = x, y
	
	local ev = createInputEvent( { eventType = mui_defs.EVENT_MouseMove } )
	if not mui.handleInputEvent( ev ) then
		notifyListeners( ev )
	end

end

local function onMouseLeft( down )
	
	local ev
	if down then
		ev = createInputEvent( { eventType = mui_defs.EVENT_MouseDown, button = mui_defs.MB_Left } )
	else
		ev = createInputEvent( { eventType = mui_defs.EVENT_MouseUp, button = mui_defs.MB_Left } )
	end
	if not mui.handleInputEvent( ev ) then
		notifyListeners( ev )
	end
end


local function onMouseMiddle( down )

	local ev
	if down then
		ev = createInputEvent( { eventType = mui_defs.EVENT_MouseDown, button = mui_defs.MB_Middle } )
	else
		ev = createInputEvent( { eventType = mui_defs.EVENT_MouseUp, button = mui_defs.MB_Middle } )
	end
end

local function onMouseRight( down )

	local ev
	if down then
		ev = createInputEvent( { eventType = mui_defs.EVENT_MouseDown, button = mui_defs.MB_Right } )
	else
		ev = createInputEvent( { eventType = mui_defs.EVENT_MouseUp, button = mui_defs.MB_Right } )
	end
	if not mui.handleInputEvent( ev ) then
		notifyListeners( ev )
	end
end

local function onMouseWheel( ... )
	for i,v in pairs({...}) do
		print(i,v)
	end
end

----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------

function getMouseXY()
	return _M._mouseX, _M._mouseY
end

function init()

	-- Register the callbacks for input
	MOAIInputMgr.device.keyboard:setCallback( onKeyboard )
	MOAIInputMgr.device.pointer:setCallback( onMouseMove )
	MOAIInputMgr.device.mouseLeft:setCallback( onMouseLeft )
	MOAIInputMgr.device.mouseMiddle:setCallback( onMouseMiddle )	
	MOAIInputMgr.device.mouseRight:setCallback( onMouseRight )
	--MOAIInputMgr.device.mouseWheel:setCallback( onMouseWheel )
end
