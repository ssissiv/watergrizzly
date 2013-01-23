-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local util = require( "modules/util" )
local mui_defs = require( "mui/mui_defs" )
local mui_button = require( "mui/widgets/mui_button" )
local mui_image = require( "mui/widgets/mui_image" )
local mui_label = require( "mui/widgets/mui_label" )
local mui_container = require( "mui/widgets/mui_container" )
require( "modules/class" )

--------------------------------------------------------
-- Local Functions

local CHECKBOX_No = 1
local CHECKBOX_Yes = 2
local CHECKBOX_Maybe = 3

local function updateImageState( self )
	self._image:setImageIndex( self._checked )
end

local function updateLayout( self, screen )
	-- Update checkbox
	local checkWidth, checkHeight = screen:uiToWndSize( self._checkSize, self._checkSize )
	checkWidth, checkHeight = screen:wndToUISize( checkHeight, checkHeight )
	
	self._image:setPosition( (checkWidth - self._w) / 2, 0 )
	self._image:setSize( checkWidth, checkHeight )
	
	-- Update label
	self._label:setPosition( checkWidth/2, 0 )
	self._label:setSize( self._w - checkWidth, self._h )
end

--------------------------------------------------------

local mui_checkbox = class()

function mui_checkbox:init( mui, def )

	self._name = def.name
	self._w, self._h = def.w, def.h
	
	self._checked = CHECKBOX_No
	self._checkSize = def.check_size
	
	self._image = mui_image( mui, { x = (def.h-def.w)/2, y = 0, w = def.h, h = def.h, images = def.images })
	
	self._label = mui_label( { x = def.h/2, y = 0, w = def.w-def.h, h = def.h, text_style = def.text_style, halign = MOAITextBox.LEFT_JUSTIFY, valign = MOAITextBox.CENTER_JUSTIFY })
	self._label:setText( def.str )
	
	self._button = mui_button( { x = 0, y = 0, w = def.w, h = def.h })
	self._button:addEventHandler( mui_defs.EVENT_ALL, self )

	self._cont = mui_container( { x = def.x, y = def.y } )
	self._image:attach( self._cont )
	self._label:attach( self._cont )
	self._button:attach( self._cont )

	updateImageState( self )
end

function mui_checkbox:findWidget( name )
	if self._name == name then
		return self
	end
end

function mui_checkbox:attach( widget )
	self._cont:attach( widget )
end

function mui_checkbox:detach( widget )
	self._cont:detach( widget )
end

function mui_checkbox:setChecked( isChecked )
	if isChecked then
		self._checked = CHECKBOX_Yes
	else
		self._checked = CHECKBOX_No
	end
	
	updateImageState( self )
end

function mui_checkbox:isChecked()
	return self._checked == CHECKBOX_Yes
end

function mui_checkbox:setPosition( x, y )
	self._cont:setPosition( x, y )
end

function mui_checkbox:handleEvent( ev )

	if ev.type == mui_defs.EVENT_OnResize then
		updateLayout( self, ev.screen )
		
	elseif ev.widget == self._button then
		if ev.type == mui_defs.EVENT_ButtonClick then
			self:setChecked( not self:isChecked() )
			return true
		elseif ev.type == mui_defs.EVENT_WidgetActivated then
			updateLayout( self, ev.screen )
			ev.screen:addEventHandler( mui_defs.EVENT_OnResize, self )
		elseif ev.type == mui_defs.EVENT_WidgetDeactivated then
			ev.screen:removeEventHandler( self )
		end
	end
end


return mui_checkbox
