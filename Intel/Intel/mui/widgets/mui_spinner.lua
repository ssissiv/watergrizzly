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

local function updateImageState( self )
	if self._leftBtn:getState() == mui_button.BUTTON_Active then
		self._leftImg:setColor( 1, 1, 0 )
	elseif self._leftBtn:getState() == mui_button.BUTTON_Hover then
		self._leftImg:setColor( 0.5, 0.5, 0 )
	else
		self._leftImg:setColor( 1, 1, 1 )
	end

	if self._rightBtn:getState() == mui_button.BUTTON_Active then
		self._rightImg:setColor( 1, 1, 0 )
	elseif self._rightBtn:getState() == mui_button.BUTTON_Hover then
		self._rightImg:setColor( 0.5, 0.5, 0 )
	else
		self._rightImg:setColor( 1, 1, 1 )
	end
	
	local item = self:getSelectedItem()
	self._label:setText( item or "" )
end

local function updateLayout( self, screen )
	local arrowWidth, arrowHeight = screen:uiToWndSize( self._arrowSize, self._arrowSize )
	arrowWidth, arrowHeight = screen:wndToUISize( arrowHeight, arrowHeight )
	
	self._leftImg:setPosition( (arrowWidth - self._w) / 2, 0 )
	self._leftImg:setSize( arrowWidth, arrowHeight )

	self._rightImg:setPosition( (self._w - arrowWidth) / 2, 0 )
	self._rightImg:setSize( arrowWidth, arrowHeight )
end

--------------------------------------------------------

local mui_spinner = class()

function mui_spinner:init( mui, def )

	self._name = def.name
	self._w, self._h = def.w, def.h
	self._selectedIndex = 0 -- 0-based
	self._items = {}
	self._arrowSize = def.arrow_size
	
	self._leftImg = mui_image( mui, { x = 0, y = 0, w = def.w, h = def.h, images = def.left_arrow_image })
	self._rightImg = mui_image( mui, { x = 0, y = 0, w = def.w, h = def.h, images = def.right_arrow_image })
	
	self._label = mui_label( { x = 0, y = 0, w = def.w, h = def.h, text_style = def.text_style, halign = MOAITextBox.CENTER_JUSTIFY, valign = MOAITextBox.CENTER_JUSTIFY })
	
	self._leftBtn = mui_button( { x = -def.w/4, y = 0, w = def.w/2, h = def.h })
	self._leftBtn:addEventHandler( mui_defs.EVENT_ALL, self )
	self._rightBtn = mui_button( { x = def.w/4, y = 0, w = def.w/2, h = def.h })
	self._rightBtn:addEventHandler( mui_defs.EVENT_ALL, self )

	self._cont = mui_container( { x = def.x, y = def.y, isVisible = def.isVisible })
	self._leftImg:attach( self._cont )
	self._rightImg:attach( self._cont )
	self._label:attach( self._cont )
	self._leftBtn:attach( self._cont )
	self._rightBtn:attach( self._cont )

	updateImageState( self )
end

function mui_spinner:findWidget( name )
	if self._name == name then
		return self
	end
end

function mui_spinner:attach( widget )
	self._cont:attach( widget )
end

function mui_spinner:detach( widget )
	self._cont:detach( widget )
end

function mui_spinner:setSelection( index )
	self._selectedIndex = index - 1

	updateImageState( self )
end

function mui_spinner:getSelection()
	return self._selectedIndex + 1 -- zero based index
end

function mui_spinner:selectPrevious()
	if #self._items > 0 then
		self._selectedIndex = (self._selectedIndex - 1) % #self._items
		updateImageState( self )
	end
end

function mui_spinner:selectNext()
	if #self._items > 0 then
		self._selectedIndex = (self._selectedIndex + 1) % #self._items
		updateImageState( self )
	end
end

function mui_spinner:getItems()
	return self._items
end

function mui_spinner:addItem( item )
	table.insert( self._items, item )
	updateImageState( self )
end

function mui_spinner:getSelectedItem()
	if self._selectedIndex >= 0 and self._selectedIndex < #self._items then
		return self._items[ self._selectedIndex + 1 ]
	end
end

function mui_spinner:setPosition( x, y )
	self._cont:setPosition( x, y )
end

function mui_spinner:handleEvent( ev )

	if ev.widget == self._leftBtn then
		if ev.type == mui_defs.EVENT_ButtonClick then
			self:selectPrevious()
			if self.onSpin then
				self:onSpin( self:getSelectedItem() )
			end
			return true
		elseif ev.type == mui_defs.EVENT_WidgetActivated then
			updateLayout( self, ev.screen )
		else
			updateImageState( self )
		end
		
	elseif ev.widget == self._rightBtn then
		if ev.type == mui_defs.EVENT_ButtonClick then
			self:selectNext()
			if self.onSpin then
				self:onSpin( self:getSelectedItem() )
			end
			return true
		else
			updateImageState( self )
		end
	end
end


return mui_spinner
