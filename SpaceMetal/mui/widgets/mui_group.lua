-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local util = require( "modules/util" )
local mui_defs = require( "mui/mui_defs" )
local mui_container = require( "mui/widgets/mui_container" )
require( "modules/class" )

--------------------------------------------------------
-- Local Functions


--------------------------------------------------------

local mui_group = class()

function mui_group:init( mui, def )

	self._name = def.name
	self._cont = mui_container( def )
	self._children = {}
	
	for i,childdef in ipairs(def.children) do
		local child = mui.createWidget(childdef)
		self:addChild( child )
	end
end

function mui_group:setPosition( x, y )
	self._cont:setPosition( x, y )
end

function mui_group:setVisible( isVisible )
	self._cont:setVisible( isVisible )
end

function mui_group:isVisible()
	return self._cont:isVisible()
end

function mui_group:attach( widget )
	self._cont:attach( widget )
end

function mui_group:detach( widget )
	self._cont:detach( widget )
end

function mui_group:findWidget( name )
	if self._name == name then
		return self
	end

	local found = nil
	for i,widget in ipairs(self._children) do
		found = widget.findWidget and widget:findWidget( name )
		if found then
			break
		end
	end
	
	return found
end

function mui_group:addChild( widget )
	table.insert( self._children, widget )
	
	widget:attach( self._cont )
end

function mui_group:removeChild( widget )
	array.removeElement( self._children, widget )
	
	widget:detach( self._cont )
end

return mui_group
