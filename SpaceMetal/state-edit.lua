--==============================================================
-- Copyright (c) 2010-2012 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
--==============================================================

local util = require( "modules/util" )
local mui = require("mui/mui")
local mui_defs = require("mui/mui_defs")
local texprop = require("modules/texprop")
local shipcomps = require("game/components")

----------------------------------------------------------------

local MODE_SELECT = 1

----------------------------------------------------------------

local stateEdit = {}

function stateEdit:selectComponent( idx )
	self.componentIdx = idx

	if self.selectProp then
		self.selectProp:destroy()
		self.selectProp = nil
	end
	
	if self.componentIdx then
		self.componentIdx = math.min( #shipcomps.all, math.max( 1, self.componentIdx ))
		self.selectProp = texprop( shipcomps.all[ self.componentIdx ].texfile, nil, self.game.layer )
		self.selectProp.prop:setPriority( 999 )
	end
end

	
----------------------------------------------------------------
stateEdit.onLoad = function ( self, game )
	log:write("EDIT: ON")
	assert( game )
	
	self.game = game
	self.game:pause( true )
	self.game:getPlayer():showEditGrid()

	self:selectComponent( 1 )
	
	self.mode = MODE_SELECT
	
	self.screen = mui.createScreen( "state-edit.lua" )
	mui.activateScreen( self.screen )
	
	inputmgr.addListener( self, 1 )
end

----------------------------------------------------------------
stateEdit.onUnload = function ( self )

	self:selectComponent()
	
	self.game:pause( false )
	self.game:getPlayer():hideEditGrid()
	
	mui.deactivateScreen( self.screen )
	self.screen = nil

	inputmgr.removeListener( self )

	log:write("EDIT: OFF")
end


----------------------------------------------------------------
stateEdit.onInputEvent = function ( self, event )

	if self.game:getCamera():onInputEvent( event ) then
		return true
	end
	
	if event.eventType == mui_defs.EVENT_KeyUp then
		if event.key == mui_defs.K_E then
			statemgr.deactivate( self )
		elseif event.key == mui_defs.K_Z then
			self:selectComponent( self.componentIdx - 1 )
		elseif event.key == mui_defs.K_X then
			self:selectComponent( self.componentIdx + 1 )
		end
		
	elseif event.eventType == mui_defs.EVENT_MouseDown then
		local x, y = self.game:wndToWorld( event.wx, event.wy )
		local gridx, gridy = self.game:getPlayer():worldToGrid( x, y )
		local component = shipcomps.all[ self.componentIdx ]()
		if self.componentIdx and self.game:getPlayer():canSetComponent( component, gridx, gridy ) then
			self.game:getPlayer():setComponent( component, gridx, gridy )
		end

	elseif event.eventType == mui_defs.EVENT_MouseMove then
		local x, y = self.game:wndToWorld( event.wx, event.wy )
		local gridx, gridy = self.game:getPlayer():worldToGrid( x, y )
		x, y = self.game:getPlayer():gridToWorld( gridx, gridy )
		self.selectProp:setLoc( x, y )
		if self.game:getPlayer():canSetComponent( shipcomps.all[ self.componentIdx ], gridx, gridy ) then
			self.selectProp:setColor( 1, 1, 1, 0.5 )
		else
			self.selectProp:setColor( 1, 0, 0, 0.5 )
		end
	end
			
	return true
end

----------------------------------------------------------------
stateEdit.onUpdate = function ( self )
	self.game:doTick(0)
end

return stateEdit
