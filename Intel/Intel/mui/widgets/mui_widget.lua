-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local mui_defs = require("mui/mui_defs")
require( "modules/class" )

local mui_widget = class()

function mui_widget:init( prop, def )
	self._x, self._y = def.x, def.y
	self._name = def.name
	self._prop = prop
	self._handlers = nil
	self._parent = nil
	self._isVisible = true

	if def.isVisible ~= nil then
		self:setVisible( def.isVisible )
	end
end

function mui_widget:destroy( screen )
	assert( self._prop )
	assert( self._parent == nil )
	
	screen:getLayer():removeProp( self._prop )
	self._prop = nil
end

function mui_widget:attach( widget )
	assert( self._parent == nil )
	self._parent = widget

	self._prop:setAttrLink( MOAIProp.INHERIT_TRANSFORM, widget._prop, MOAIProp.TRANSFORM_TRAIT)
	self._prop:setAttrLink( MOAIProp.ATTR_VISIBLE, widget._prop, MOAIProp.ATTR_VISIBLE)

	widget:addWidget( self )
end

function mui_widget:detach( widget )
	widget:removeWidget( self )
	
	self._prop:clearAttrLink( MOAIProp.INHERIT_TRANSFORM )
	self._prop:clearAttrLink( MOAIProp.ATTR_VISIBLE )

	assert( self._parent == widget )
	self._parent = nil
end


function mui_widget:findWidget( name )
	if self._name == name then
		return self
	end
end
	
function mui_widget:getScreen()

	local parent = self._parent
	while parent and parent._parent ~= nil do
		parent = parent._parent
	end
	
	return parent
end

function mui_widget:getPosition()
	return self._prop:getLoc()
end

function mui_widget:setPosition( x, y )
	self._x, self._y = x, y
	self._prop:setLoc( self._x, self._y )
end

function mui_widget:getPriority()
	return self._prop:getPriority()
end

function mui_widget:updatePriority( priority )
	self._prop:setPriority( priority )
	return priority
end


function mui_widget:getProp()
	return self._prop
end

function mui_widget:setVisible( isVisible )
	self._isVisible = isVisible
	self._prop:setVisible( isVisible )
end

function mui_widget:isVisible()
	return self._isVisible
end

function mui_widget:recurse( fn, ... )
	fn( self, ... )
end

function mui_widget:onActivate( screen )
	screen:getLayer():insertProp( self._prop )
	self:setPosition( self._x, self._y )
	
	self:dispatchEvent( { type = mui_defs.EVENT_WidgetActivated, widget = self, screen = screen } )
end

function mui_widget:onDeactivate( screen )
	screen:getLayer():removeProp( self._prop )

	self:dispatchEvent( { type = mui_defs.EVENT_WidgetDeactivated, widget = self, screen = screen } )
end

function mui_widget:handleInputEvent( ev )
	return false
end

function mui_widget:addEventHandler( evType, handler )
	
	if not self._handlers then
		self._handlers = {}
	end

	if not self._handlers[evType] then
		self._handlers[evType] = {}
	end
	
	table.insert( self._handlers[evType], handler )
end

function mui_widget:removeEventHandler( handler )
	assert( self._handlers )

	for i,handlers in ipairs( self._handlers ) do
		array.remove( handlers, handler )
	end
end

function mui_widget:dispatchEvent( ev )
	assert( ev.type )
	
	if self._handlers then
		if self._handlers[mui_defs.EVENT_ALL] then
			for i,handler in ipairs( self._handlers[mui_defs.EVENT_ALL] ) do
				if handler:handleEvent( ev ) then
					return
				end
			end
		end

		if self._handlers[ev.type] then
			for i,handler in ipairs( self._handlers[ev.type] ) do
				if handler:handleEvent( ev ) then
					return
				end
			end
		end
	end
end


return mui_widget

