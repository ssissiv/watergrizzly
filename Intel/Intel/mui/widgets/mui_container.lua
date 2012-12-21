-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local mui_widget = require( "mui/widgets/mui_widget" )
require( "modules/class" )

local mui_container = class( mui_widget )

function mui_container:init( def )
	mui_widget.init( self, MOAIProp2D.new(), def )
	self._children = {}
end

function mui_container:updatePriority( priority )
	mui_widget.updatePriority( self, priority )
	
	for i,widget in ipairs(self._children) do
		priority = widget:updatePriority( priority + 1 )
	end
	return priority
end

function mui_container:recurse( fn, ... )
	mui_widget.recurse( self, fn, ... )

	for i,widget in ipairs(self._children) do
		widget:recurse( fn, ... )
	end
end

function mui_container:handleInputEvent( ev )
	if not self:isVisible() then
		return false
	end

	for i,widget in ipairs(self._children) do
		if widget:handleInputEvent( ev ) then
			return true
		end
	end

	return false
end


function mui_container:addWidget( widget )
	assert( not array.find( self._children, widget ))
	assert( widget._parent == self )
	
	table.insert( self._children, widget )
	
	if self:getScreen() then
		self:getScreen():onAddWidget( widget )
	end
end

function mui_container:removeWidget( widget )
	assert( array.find( self._children, widget ))
	
	array.removeElement( self._children, widget )
		
	if self:getScreen() then
		self:getScreen():onRemoveWidget( widget )
	end
end

return mui_container

