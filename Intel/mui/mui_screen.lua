-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local mui_container = require( "mui/widgets/mui_container" )
local mui_defs = require( "mui/mui_defs" )
local mui_util = require("mui/mui_util")
local mui_binder = require("mui/mui_binder")
require( "modules/class")

local mui_screen = class()

local ACTIVE_PRIORITY = 1 -- static incrementing value

----------------------------------------------------------
-- Local Functions
----------------------------------------------------------
	
function mui_screen:init( props, filename )
	self._root = mui_container( { x = 0, y = 0 } )
	self._root._parent = self
	self._widgets = {}
	self._propToWidget = {}
	self._handlers = {}
	self._focusWidgets = {}
	self._layer = nil
	self._viewport = nil
	self._camera = nil
	self._priority = nil
	self._isEnabled = true
	self._props = props or { sinksInput = true }
	self._filename = filename
	
	self.binder = mui_binder.create( self )
end

function mui_screen:wndToUI( x, y )
	return self._layer:wndToWorld( x, y )
end

function mui_screen:uiToWnd( x, y )
	return self._layer:worldToWnd( x, y )
end

function mui_screen:wndToUISize( x, y )
	local x0, y0 = self._layer:wndToWorld( 0, 0 )
	x, y = self._layer:wndToWorld( x, y )
	
	return x - x0, y0 - y
end

function mui_screen:uiToWndSize( x, y )
	local x0, y0 = self._layer:worldToWnd( 0, 0 )
	local x1, y1 = self._layer:worldToWnd( x, y )

	return math.abs(x1 - x0), math.abs(y1 - y0)
end

function mui_screen:getLayer()
	return self._layer
end

function mui_screen:setVisible( isVisible )
	self._root:setVisible( isVisible )
end

function mui_screen:isVisible()
	return self._root:isVisible()
end

function mui_screen:setEnabled( isEnabled )
	self._isEnabled = isEnabled
	-- TODO: clear focus widgets or somehow handle cleaning up widgets in the process of handling stuff
end

function mui_screen:isEnabled()
	return self._isEnabled
end

function mui_screen:setPriority( priority )
	self._priority = priority
end

function mui_screen:getPriority()
	return self._priority
end

function mui_screen:addWidget( widget )
	table.insert( self._widgets, widget )
	widget:attach( self._root )
end

function mui_screen:removeWidget( widget )
	array.removeElement( self._widgets, widget )
	widget:detach( self._root )
end

function mui_screen:findWidget( name )
	local found = nil
	for i,widget in ipairs(self._widgets) do
		found = widget.findWidget and widget:findWidget( name )
		if found then
			break
		end
	end
	
	return found
end

function mui_screen:onAddWidget( widget )

	widget:recurse(
		function( widget )
			self._propToWidget[ widget:getProp() ] = widget
			if self:isActive() then
				widget:onActivate( self )
			end
		end )

	if self:isActive() then
		self:refreshPriority()
	end
end

function mui_screen:onRemoveWidget( widget )
	widget:recurse(
		function( widget )
			self._propToWidget[ widget:getProp() ] = nil
			if self:isActive() then
				widget:onDeactivate( self )
				array.removeElement( self._focusWidgets, widget )
			end
		end )
end


function mui_screen:refreshPriority()
	self._root:updatePriority( 0 )
end

function mui_screen:handleInputEvent( ev )

	local handled = false

	if self:isEnabled() then
		local widget = self:getFocus()

		if not widget then	
			if mui_util.isMouseEvent( ev ) then
				local props = {self._layer:getPartition():propListForPoint(ev.x, ev.y, 0, MOAILayer.SORT_PRIORITY_DESCENDING)}

				for i,prop in ipairs(props) do
					if prop:shouldDraw() then
						widget = self._propToWidget[ prop ]
						assert(widget)
						break
					end
				end
			else
				widget = self._root
			end
		end

		if widget then
			handled = widget:handleInputEvent( ev )
		end
	end
	
	return handled or self._props.sinksInput
end

function mui_screen:addEventHandler( evType, handler )
	
	if not self._handlers[evType] then
		self._handlers[evType] = {}
	end
	
	table.insert( self._handlers[evType], handler )
end

function mui_screen:removeEventHandler( handler )

	for i,handlers in ipairs( self._handlers ) do
		array.remove( handlers, handler )
	end
end

function mui_screen:dispatchEvent( ev )
	
	if self._handlers[ev.type] then
		for i,handler in ipairs( self._handlers[ev.type] ) do
			if handler:handleEvent( ev ) then
				return true
			end
		end
	end

	return false
end

function mui_screen:isActive()
	return self._layer ~= nil
end

function mui_screen:onResize( width, height )

	self._viewport:setSize ( width, height )
	self._viewport:setScale( width, height )

	self._camera:setScl( 1/width, 1/height )
	self._camera:forceUpdate()
	
	self:dispatchEvent( { type = mui_defs.EVENT_OnResize, screen = self } )
end

function mui_screen:onActivate( width, height )
	assert( self._layer == nil )

	local viewport = MOAIViewport.new ()
	viewport:setSize ( width, height )
	viewport:setScale( width, height )
	self._viewport = viewport

	local layer = MOAILayer2D.new ()
	layer:setViewport ( viewport )

	local camera = MOAICamera2D.new()
	camera:setScl( 1/(width), 1/(height) )
	camera:setLoc( 0.5, 0.5 )
	camera:forceUpdate()
	layer:setCamera( camera )
	self._camera = camera
	
	self._layer = layer
	self._priority = ACTIVE_PRIORITY
	ACTIVE_PRIORITY = ACTIVE_PRIORITY + 1

	self._root:recurse(
		function( widget )
			widget:onActivate( self )
		end )
		
	self:refreshPriority()
end

function mui_screen:onDeactivate()
	assert( self._layer )

	self._priority = nil

	self._root:recurse(
		function( widget )
			widget:onDeactivate( self )
		end )
	self._layer = nil
end

function mui_screen:lockFocus( widget )
	assert(not array.find( self._focusWidgets, widget ))
	
	table.insert( self._focusWidgets, widget )
end

function mui_screen:unlockFocus( widget )
	assert(array.find( self._focusWidgets, widget ))
	
	array.removeElement( self._focusWidgets, widget )
end

function mui_screen:getFocus()
	if #self._focusWidgets == 0 then
		return nil
	else
		return self._focusWidgets[ #self._focusWidgets ]
	end
end


return mui_screen
