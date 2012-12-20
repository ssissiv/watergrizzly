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

local IMAGE_Inactive = 1
local IMAGE_Hover = 2
local IMAGE_Active = 3

local function updateImageState( self )
	if self._button:getState() == mui_button.BUTTON_Inactive then
		self._image:setImageIndex( IMAGE_Inactive )
		self._image:setScale( 1, 1 )
	elseif self._button:getState() == mui_button.BUTTON_Active then
		self._image:setImageIndex( IMAGE_Active )
		self._image:setScale( 0.8, 0.8 )
	elseif self._button:getState() == mui_button.BUTTON_Hover then
		self._image:setImageIndex( IMAGE_Hover )
		self._image:setScale( 1.2, 1.2 )
	end
end

--------------------------------------------------------

local mui_imagebutton = class()

function mui_imagebutton:init( mui, def )

	self._name = def.name
	self._image = mui_image( mui, { x = 0, y = 0, w = def.w, h = def.h, images = def.images })
	
	self._label = mui_label( { x = 0, y = 0, w = def.w, h = def.h, text_style = def.text_style, halign = def.halign, valign = def.valign, str = def.str } )
	
	self._button = mui_button( { x = 0, y = 0, w = def.w, h = def.h, hotkey = def.hotkey })
	self._button:addEventHandler( mui_defs.EVENT_ALL, self )

	self._cont = mui_container( { x = def.x, y = def.y, isVisible = def.isVisible } )
	self._image:attach( self._cont )
	self._label:attach( self._cont )
	self._button:attach( self._cont )

	updateImageState( self )
end

function mui_imagebutton:setPosition( x, y )
	self._cont:setPosition( x, y )
end

function mui_imagebutton:setText( str )
	self._label:setText( str )
end

function mui_imagebutton:setInactiveImage( str )
	self._image:setImageAtIndex( str, IMAGE_Inactive )
	updateImageState(self)
end

function mui_imagebutton:setActiveImage( str )
	self._image:setImageAtIndex( str, IMAGE_Active )
	updateImageState(self)
end

function mui_imagebutton:setHoverImage( str )
	self._image:setImageAtIndex( str, IMAGE_Hover )
	updateImageState(self)
end

function mui_imagebutton:findWidget( name )
	if self._name == name then
		return self
	end
end

function mui_imagebutton:attach( widget )
	self._cont:attach( widget )
end

function mui_imagebutton:detach( widget )
	self._cont:detach( widget )
end

function mui_imagebutton:setVisible( isVisible )
	self._cont:setVisible( isVisible )
end

function mui_imagebutton:isVisible()
	return self._cont:isVisible()
end


function mui_imagebutton:handleEvent( ev )

	if ev.widget == self._button then
		updateImageState( self )

		if ev.type == mui_defs.EVENT_ButtonClick then
			if self.onClick then
				util.callDelegate( self.onClick, ev.ie )
			end
			return true
		end
	end
end


return mui_imagebutton
