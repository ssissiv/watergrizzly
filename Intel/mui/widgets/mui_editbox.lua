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

local function isLegalKey( key )
	local res = pcall( string.char, key )

	return res
end

local function createTextBox( w, h, text_style )
	assert( text_style )
	
	local prop = MOAITextBox.new()
	prop:setRect( -w/2, -h/2, w/2, h/2 )
	prop:setStyle( text_style )
	prop:setAlignment( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY )
	prop:setYFlip ( true )
	
	return prop
end

--------------------------------------------------------

local mui_editbox = class( mui_widget )

function mui_editbox:init( def )
	mui_widget.init( self, createTextBox( def.w, def.h, def.text_style ), def )
	self._str = ""
	self._cursor = -1
end

function mui_editbox:setSize( w, h )
	self._prop:setRect( -w/2, -h/2, w/2, h/2 )
end

function mui_editbox:setColor( r, g, b, a )
	self._prop:setColor( r, g, b, a )
end

function mui_editbox:getText()
	return self._str
end

function mui_editbox:setText( str )
	self._str = str or ""

	local displayStr
	if self._pwchar then
		displayStr = self._pwchar:rep( #self._str )
	else
		displayStr = self._str
	end
	if self._cursor >= 0 and self._cursor <= #self._str then
		displayStr = displayStr:sub(0, self._cursor) .. "|" .. displayStr:sub(self._cursor + 1, #displayStr)
	end

	self._prop:setString( displayStr )
end

function mui_editbox:setPasswordChar( pwchar )
	assert(pwchar == nil or (type(pwchar) == "string" and #pwchar == 1))

	self._pwchar = pwchar
	self:setText( self._str )
end

function mui_editbox:onActivate( screen )
	mui_widget.onActivate( self, screen )
	
	screen:addEventHandler( mui_defs.EVENT_OnResize, self )
end

function mui_editbox:onDeactivate( screen )
	mui_widget.onDeactivate( self, screen )

	screen:removeEventHandler( mui_defs.EVENT_OnResize, self )
end

function mui_editbox:handleEvent( ev )
	if ev.type == mui_defs.EVENT_OnResize then
		self._prop:setStyle( self._prop:getStyle() )
	end
end

function mui_editbox:insertAtCursor( str )
	if self._cursor >= 0 and self._cursor <= #self._str then
		self._str = self._str:sub(0, self._cursor) .. str .. self._str:sub( self._cursor + 1, #self._str )
		self._cursor = self._cursor + 1
		self:setText( self._str )
	end
end

function mui_editbox:deleteAtCursor()
	if self._cursor >= 1 and self._cursor <= #self._str then
		self._str = self._str:sub(0, self._cursor - 1) .. self._str:sub( self._cursor + 1, #self._str )
		self._cursor = self._cursor - 1
		self:setText( self._str )
	end
end


function mui_editbox:startEditing()
	self:getScreen():lockFocus( self )
	self._cursor = #self._str
	self:setText( self._str )
end


function mui_editbox:finishEditing()
	self:getScreen():unlockFocus( self )
	self._cursor = -1
	self:setText( self._str )
end


function mui_editbox:handleInputEvent( ev )

	if ev.type == mui_defs.EVENT_KeyDown then
		if ev.key == mui_defs.K_BACKSPACE then
			self:deleteAtCursor( )
		elseif ev.key == mui_defs.K_ENTER then
			self:finishEditing( )
		elseif isLegalKey( ev.key ) then
			self:insertAtCursor( string.char(ev.key) )
		end
		return true
		
	elseif ev.type == mui_defs.EVENT_MouseDown and ev.button == mui_defs.MB_Left then
		assert( self._prop )
		if self._prop:inside( ev.x, ev.y ) then
			if self:getScreen():getFocus() ~= self then
				self:startEditing()
			else
				-- readjust cursor
			end
		else
			self:finishEditing()
		end
		return true
	end
end

return mui_editbox

