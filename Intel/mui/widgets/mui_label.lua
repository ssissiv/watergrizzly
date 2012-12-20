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

local function createTextBox( w, h, text_style, halign, valign )
	assert( text_style )
	
	local prop = MOAITextBox.new()
	prop:setRect( -w/2, -h/2, w/2, h/2 )
	prop:setStyle( text_style )
	prop:setAlignment( halign, valign )
	prop:setYFlip ( true )
	
	return prop
end

--------------------------------------------------------

local mui_label = class( mui_widget )

function mui_label:init( def )
	mui_widget.init( self, createTextBox( def.w, def.h, def.text_style, def.halign, def.valign ), def )

	self._w, self._h = def.w, def.h
	self:setText( def.str )
end

function mui_label:getSize()
	return self._w, self._h
end

function mui_label:setSize( w, h )
	self._w, self._h = w, h
	self._prop:setRect( -w/2, -h/2, w/2, h/2 )
end

function mui_label:setColor( r, g, b, a )
	self._prop:setColor( r, g, b, a )
end

function mui_label:setText( str )
	self._prop:setString( str or "" )
end

function mui_label:onActivate( screen )
	mui_widget.onActivate( self, screen )
	
	screen:addEventHandler( mui_defs.EVENT_OnResize, self )
end

function mui_label:onDeactivate( screen )
	mui_widget.onDeactivate( self, screen )

	screen:removeEventHandler( mui_defs.EVENT_OnResize, self )
end

function mui_label:handleEvent( ev )
	if ev.type == mui_defs.EVENT_OnResize then
		self._prop:setStyle( self._prop:getStyle() )
	end
end

return mui_label

