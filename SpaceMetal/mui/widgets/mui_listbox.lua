-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

local array = require( "modules/array" )
local util = require( "modules/util" )
local mui_defs = require( "mui/mui_defs" )
local mui_button = require( "mui/widgets/mui_button" )
local mui_image = require( "mui/widgets/mui_image" )
local mui_container = require( "mui/widgets/mui_container" )
require( "modules/class" )

--------------------------------------------------------
-- Local Functions

local ITEM_Inactive = 1
local ITEM_Active = 2
local ITEM_Hover = 3

local function updateItem( self, item )
	if item.image then
		if item.hitbox:getState() == mui_button.BUTTON_Inactive then
			item.image:setImageIndex( ITEM_Inactive )
		elseif item.hitbox:getState() == mui_button.BUTTON_Active then
			item.image:setImageIndex( ITEM_Active )
		elseif item.hitbox:getState() == mui_button.BUTTON_Hover then
			item.image:setImageIndex( ITEM_Hover )
		end
	end
end

local function calculateItemY( listbox, idx )
	-- TODO: calculate item height dynamically instead of hijacking spcaing
	local item_height = listbox._item_spacing

	-- top_of_listbox - half_item_height - (zero_based_idx * item_height)
	return (listbox._h / 2) - 0.5 * item_height - (idx - 1) * item_height
end

local function updateItemPosition( listbox, idx )
	local y = calculateItemY( listbox, idx )
	local item = listbox._items[idx]
	
	if y + listbox._item_spacing / 2 < -listbox._h / 2 then
		if item.isAttached then
			item.isAttached = false
			item.cont:detach( listbox._cont )
		end
	else
		if not item.isAttached then
			item.isAttached = true
			item.cont:attach( listbox._cont )
			item.cont:setPosition( 0, y )
		end
	end
end


local function createItem( listbox, user_data )
	local item = {}

	item.cont = mui_container( { x=0, y=0} )
	
	if listbox._item_images then
		item.image = mui_image( listbox._mui, {x=0, y=0, w=listbox._w, h=listbox._item_spacing, images=listbox._item_images} )
		item.image:attach( item.cont )
	end

	item.widget = listbox._item_ctor()
	item.widget:attach( item.cont )

	item.hitbox = mui_button( {x=0, y=0, w=listbox._w, h=listbox._item_spacing} )
	item.hitbox:addEventHandler( mui_defs.EVENT_ALL, listbox )
	item.hitbox:attach( item.cont )

	item.user_data = user_data
	
	return item
end

--------------------------------------------------------

local mui_listbox = class()

function mui_listbox:init( mui, def )

	self._mui = mui
	self._name = def.name
	self._item_ctor = function() return mui.createWidget( { skin = def.item_template } ) end
	self._item_spacing = def.item_spacing
	self._item_images = def.images
	self._selectedIndex = nil
	self._w, self._h = def.w, def.h
	self._cont = mui_container( { x = def.x, y = def.y, isVisible = def.isVisible } )
	self._items = {}
end

function mui_listbox:setPosition( x, y )
	self._cont:setPosition( x, y )
end

function mui_listbox:setVisible( isVisible )
	self._cont:setVisible( isVisible )
end

function mui_listbox:isVisible()
	return self._cont:isVisible()
end

function mui_listbox:attach( widget )
	self._cont:attach( widget )
end

function mui_listbox:detach( widget )
	self._cont:detach( widget )
end

function mui_listbox:findWidget( name )
	if self._name == name then
		return self
	end

	local found = nil
	for i,item in ipairs(self._items) do
		found = item.widget:findWidget( name )
		if found then
			break
		end
	end
	
	return found
end

function mui_listbox:handleEvent( ev )

	-- find the associated hitbox
	for i,item in ipairs(self._items) do
		if item.hitbox == ev.widget then
			updateItem( self, item )
			if ev.type == mui_defs.EVENT_ButtonClick then
				self:selectIndex( i )
			end
			break
		end
	end

	return true
end

function mui_listbox:addItem( user_data )
	
	local item = createItem( self, user_data )
	table.insert( self._items, item )
	
	updateItemPosition( self, #self._items )
	
	return item.widget
end

function mui_listbox:removeItem( idx )
	
	if idx > 0 and idx <= #self._items then
		local item = self._items[idx]

		if item.isAttached then
			item.cont:detach( self._cont )
		end
		table.remove( self._items, idx )
		
		if self._selectedIndex == idx then
			self:selectIndex( nil )
		end
		
		for i = idx,#self._items do
			updateItemPosition( self, i )
		end
	end
end

function mui_listbox:getItemCount()
	return #self._items
end

function mui_listbox:clearItems()

	self:selectIndex( nil )

	while #self._items > 0 do
		self:removeItem( 1 )
	end
end

function mui_listbox:selectIndex( idx )
	local old_idx = self._selectedIndex
	local new_idx = idx

	if old_idx ~= new_idx then
		self._selectedIndex = new_idx

		if self.onItemSelected then
			if self._selectedIndex then
				util.callDelegate( self.onItemSelected, old_idx, new_idx, self._items[ self._selectedIndex ].user_data )
			else
				util.callDelegate( self.onItemSelected, old_idx, new_idx )
			end
		end
	end
end

function mui_listbox:getSelectedIndex()
	return self._selectedIndex
end

function mui_listbox:getSelectedItem()
	if self._selectedIndex then
		return self._items[ self._selectedIndex ].user_data
	end
	
	return nil
end

return mui_listbox
